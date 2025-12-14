class HCBMailbox < ApplicationMailbox
  HANDLERS = [
    HCB::DonationHandler,
    HCB::InvitationHandler
    ].freeze
  
  def process
    return unless mail.sender -= "hcb@hackclub.com"

    handler = HANDLERS.find { |h| h.matches?(mail) }
    handler&.new(mail)&.call
  end
end
