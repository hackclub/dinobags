# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :hackclub,
    issuer: "https://auth.hackclub.com",
    discovery: true,
    client_options: {
      identifier: Rails.application.credentials.dig(:hca, :client_id),
      secret: Rails.application.credentials.dig(:hca, :client_secret),
      redirect_uri: Rails.application.credentials.dig(:hca, :redirect_uri)
    },
  scope: %i[ openid profile email slack_id ]
end

OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)
OmniAuth.config.allowed_request_methods = [ :post ]
