class ApplicationController < ActionController::Base
  include Pundit::Authorization
  after_action :verify_authorized, unless: :skip_pundit?

  helper_method :current_user, :user_signed_in?

  before_action :authenticate_user!

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    !!current_user
  end

  def authenticate_user!
    unless user_signed_in?
      redirect_to root_path, alert: "login, silly"
    end
  end

  rescue_from Pundit::NotAuthorizedError do |e|
    flash[:error] = "hey, you cn't do that!"
    redirect_to root_path
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    flash[:error] = "oops! looks like we dropped that record in the trash..."
    redirect_to root_path
  end

  private

  def skip_pundit?
    self.class.module_parent_name&.start_with?("MissionControl")
  end
end
