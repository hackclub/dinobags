class DashboardController < ApplicationController
  layout "dashboard"
  skip_after_action :verify_authorized

  def index
  end
end
