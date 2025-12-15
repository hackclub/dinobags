class HCBError < StandardError; end
class HCBUnauthorizedError < HCBError; end

# Middleware: raise specific error for 401 so we can refresh + retry,
# and raise generic HCBError for other non-success responses.
class RaiseHCBErrorMiddleware < Faraday::Middleware
  def on_complete(env)
    status = env.status
    body = env.body

    if status == 401
      raise HCBUnauthorizedError, "HCB returned 401: #{body}"
    end

    raise HCBError, "HCB returned #{status}: #{body}" unless env.response.success?
  end
end

Faraday::Response.register_middleware hcb_error: RaiseHCBErrorMiddleware

module HCBService
  class << self
    def base_url
      hcb_credentials = HCBCredential.first
      hcb_credentials.base_url if hcb_credentials && hcb_credentials.base_url.present? or "https://hcb.hackclub.com"
    end

    # Generic wrapper that will attempt a token refresh on 401 once, then retry.
    def with_retry
      attempts = 0
      begin
        yield
      rescue HCBUnauthorizedError
        attempts += 1
        if attempts <= 1 && refresh_token!
          retry
        end
        raise
      end
    end

    def refresh_token!
      HCBCredential.transaction do
        hcb_credentials = HCBCredential.first
        raise HCBError, "no HCB credentials found" unless hcb_credentials
        client_id = hcb_credentials.client_id
        client_secret = hcb_credentials.client_secret
        refresh_token = hcb_credentials.refresh_token
        redirect_uri = hcb_credentials.redirect_uri
        base = hcb_credentials.base_url || base_url

        # Use a lightweight connection to call the token endpoint to avoid recursion.
        # Doorkeeper expects a form-encoded POST (application/x-www-form-urlencoded).
        token_conn = Faraday.new(url: "#{base}/api/v4/") do |f|
          f.request :url_encoded
          f.response :json, content_type: /\bjson$/
          f.adapter :net_http
          f.headers["Accept"] = "application/json"
        end

        message = {
          client_id: client_id,
          client_secret: client_secret,
          refresh_token: refresh_token,
          redirect_uri: redirect_uri,
          grant_type: "refresh_token"
        }

        # Send form-encoded params (not JSON) so Doorkeeper accepts the refresh request.
        resp = token_conn.post("oauth/token", message)

        unless resp.success?
          error_msg = resp.body.is_a?(Hash) ? resp.body["error"] || resp.body[:error] : resp.body
          raise HCBError, "token refresh failed with status #{resp.status}: #{error_msg}"
        end

        body = resp.body
        access_token = body && (body["access_token"] || body[:access_token])
        new_refresh_token = body && (body["refresh_token"] || body[:refresh_token])
        raise HCBError, "no access_token in response: #{body}" unless access_token

        hcb_credentials.update!(refresh_token: new_refresh_token, access_token: access_token)
        @conn = nil

        true
      rescue Faraday::Error => e
        raise HCBError, "token refresh HTTP error: #{e.message}"
      rescue => e
        raise HCBError, "token refresh failed: #{e.message}"
      end
    end

    def topup_card_grant(hashid:, amount_cents:, slug:)
      Rails.logger.info "Topping up HCB card grant #{hashid} by #{amount_cents}¢"
      txn = with_retry { conn.post("card_grants/#{hashid}/topup?expand=disbursements,user", amount_cents:).body }
      purpose = txn.dig(:purpose)
      txn_id = txn.dig(:disbursements, 0, :transaction_id)
      name = txn.dig(:user, :name)

      memo = "[grant] topping up #{name}'s #{purpose}"
      rename_transaction(hashid: txn_id, slug:, new_memo: memo)

      txn_id
    end

    def rename_transaction(hashid:, slug:, new_memo:)
      Rails.logger.info "Rename on #{slug} for #{hashid} to #{new_memo}"
      with_retry { conn.put("organizations/#{slug}/transactions/#{hashid}", memo: new_memo).body }
    end

    def list_invitations
      with_retry { conn.get("user/invitations").body }
    end

    def accept_invitation(id:)
      with_retry { conn.post("user/invitations/#{id}/accept") }
    end

    def reject_invitation(id:)
      with_retry { conn.post("user/invitations/#{id}/reject") }
    end

    # Builds (or returns cached) Faraday connection for HCB API.
    # Uses Bearer token from HCBCredential for OAuth authentication.
    def conn
      hcb_creds = HCBCredential.first
      raise HCBError, "no HCB credentials found" unless hcb_creds
      hcb_access_token = hcb_creds.access_token

      @conn ||= Faraday.new url: "#{hcb_creds.base_url || base_url}/api/v4/" do |faraday|
        faraday.request :json
        faraday.response :mashify
        faraday.response :json
        faraday.response :hcb_error
        faraday.headers["Authorization"] = "Bearer #{hcb_access_token}"
      end
    end
  end
end
