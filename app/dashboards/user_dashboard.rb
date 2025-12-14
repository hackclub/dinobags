class UserDashboard < BaseDashboard
  def display_resource(user)
    user.name || user.email || "User ##{user.id}"
  end
end
