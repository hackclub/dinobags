module HCB
  class InvitationHandler
    def self.matches?(mail)
      mail.subject.match?(/invited to join/)
    end

    def initialize(mail) = @mail = mail

    def call
      Rails.logger.info("Processing new invitation")

      invites = HCBService.list_invitations
      invites.each do |invite|
        if invite.dig(:role) == "manager"
          Rails.logger.info("Accepting manager invite to #{invite.dig(:organization, :name)} from #{invite.dig(:sender, :name)}")

          HCBService.accept_invitation(id: invite.dig(:id))
        else
          Rails.logger.info("Rejecting #{invite.dig(:role)} invite to #{invite.dig(:organization, :name)} from #{invite.dig(:sender, :name)}")

          HCBService.reject_invitation(id: invite.dig(:id))
        end
      end
    end
  end
end
