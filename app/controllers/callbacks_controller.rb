class CallbacksController
  def omniauth
    auth = request.env.dig("omniauth.auth")

    user = User.find_or_create_by(identity_id: auth.dig("sub")) do |user|
      user.name = auth.dig("name")
      user.email = auth.dig("email")
      user.slack_id = auth.dig("slack_id")
    end

    session[:user_id] = user.id
    redirect_to root_path, notice: "Successfully logged in :D"
  end
end
