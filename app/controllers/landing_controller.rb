class LandingController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def index
    redirect_to dashboard_path if user_signed_in?
  end
end
