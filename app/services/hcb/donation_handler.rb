module HCB
  class DonationHandler
    def self.matches?(mail)
      mail.subject.match?(/received a donation|received your first donation/)
    end

    def initialize(mail) = @mail = mail

    def call
      body = @mail.body.decoded
      grant_id = body.split("grants/").last.to_s.split(/[^a-zA-Z0-9]/).first
      hash_id = "cdg_#{grant_id}"

      don_id = "don_#{body.split("donations/").last.to_s.split(/[\/\s]/).first.remove('"')}"

      return if grant_id.blank?

      return if Topup.find_by(don_id:)

      begin
        donation_data = Faraday.get("#{HCBService.base_url}/api/v3/donations/#{don_id}?expand=organization")
      rescue StandardError => e
        Rails.logger.error("Error fetching donation details for don_#{don_id}. #{e.message}")
        return
      end

      return Rails.logger.error("Failed to fetch donation details for #{don_id}") unless donation_data.success?

      donation_json = JSON.parse(donation_data.body)
      amount_cents = donation_json.dig("amount_cents")
      slug = donation_json.dig("organization", "slug")

      return Rails.logger.error("Donation amount not found") unless amount_cents

      Rails.logger.info("Processing #{amount_cents}¢ donation for #{slug} on #{hash_id}")

      begin
        txn_id = HCBService.topup_card_grant(
          hashid: hash_id,
          amount_cents:,
          slug:
        )
      rescue => e
        Rails.logger.error "Error topping up grant #{hash_id} with #{amount_cents} on #{slug}: #{e.message}"
        return
      end

      Topup.create(
        txn_id:,
        amount_cents:,
        don_id:,
        slug:,
        cdg_id: hash_id
      )
    end
  end
end
