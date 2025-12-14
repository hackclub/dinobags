class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :omniauth_failure, :hackclub_callback ]

  skip_after_action :verify_authorized

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "cya later!"
  end

  def omniauth_failure
    auth = request.env["omniauth.auth"]
  end

  def hackclub_callback
    auth = request.env["omniauth.auth"]

    if auth.nil?
      redirect_to root_path, alert: "Auth failed D:"
      return
    end

    begin
      @user = User.from_hack_club_auth(auth)
    rescue => e
      Rails.logger.error "Error creating HCA user: #{e.message}"
      redirect_to root_path "something went wrong with auth D:"
      return
    end

    if @user&.persisted?
      session["user_id"] = @user.id
      flash[:success] = "welcome aboard!"
      redirect_to root_path
    else
      Rails.logger.error "Failed to create/update HCA user"
      redirect_to root_path, alert: "uh oh! this shouldn't happen"
    end
  end
end
