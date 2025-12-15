class LandingController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def index
    # redirect_to dashboard_path if user_signed_in?

    begin
      1 / 0
    rescue ZeroDivisionError => exception
      Rails.logger.info "waa"
      Sentry.capture_exception(exception)
    end

    Sentry.capture_message("test message")

    @total_transferred = Topup.sum(:amount_cents)
    @total_txns = Topup.count
  end
end
