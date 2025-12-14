class HCBCredentialDashboard < BaseDashboard
  def display_resource(credential)
    "HCB Credential ##{credential.id}"
  end
end
