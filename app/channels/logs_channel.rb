class LogsChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user&.admin?
    stream_from "logs_stream"
  end

  def unsubscribed
    stop_all_streams
  end

  def request_logs(data)
    return unless current_user&.admin?

    lines = (data["lines"] || 100).to_i.clamp(1, 1000)
    log_output = fetch_logs(lines)

    transmit({ logs: log_output })
  end

  private

  def fetch_logs(lines)
    log_file = Rails.root.join("log", "#{Rails.env}.log")

    if File.exist?(log_file)
      `tail -n #{lines} "#{log_file}"`
    else
      "Log file not found."
    end
  rescue => e
    "Error reading logs: #{e.message}"
  end
end
