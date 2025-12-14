module HCB
  class InvitationHandler
    def self.matches?(mail)
      mail.subject.match?(/invited to join/)
    end

    def initialize(mail) = @mail = mail

    def call
      invites = HCBService.list_invitations
      invites.each do |invite|
        if invite.dig(:role) == "manager"
          HCBService.accept_invitation(invite.dig(:id))
        else
          HCBService.reject_invitation(invite.dig(:id))
        end
      end
    end
  end
end
