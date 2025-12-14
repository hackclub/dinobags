class HCBMailbox < ApplicationMailbox
  HANDLERS = [
    HCB::DonationHandler,
    HCB::InvitationHandler
    ].freeze

  def process
    Rails.logger.info("Processing #{mail.subject} from #{mail.sender}")

    handler = HANDLERS.find { |h| h.matches?(mail) }
    handler&.new(mail)&.call
  end
end
