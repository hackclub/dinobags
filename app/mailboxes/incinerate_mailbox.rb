class IncinerateMailbox < ApplicationMailbox
  def process
    Rails.logger.info("Incinerating #{mail.subject} from #{mail.sender}")
  end
end
