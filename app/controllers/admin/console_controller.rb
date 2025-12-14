module Admin
  class ConsoleController < ApplicationController
    layout "dashboard"
    before_action :require_admin!

    @@console_bindings = {} # rubocop:disable Style/ClassVars

    def show
      @output = nil
      @lines = params.fetch(:lines, 100).to_i.clamp(1, 1000)
      @log_output = fetch_logs(@lines)
    end

    def execute
      unless current_user&.admin?
        redirect_to root_path, alert: "Not authorized"
        return
      end

      code = params[:code].to_s
      @output = execute_code(code)
      @lines = params.fetch(:lines, 100).to_i.clamp(1, 1000)
      @log_output = fetch_logs(@lines)
      render :show
    end

    def logs
      lines = params.fetch(:lines, 100).to_i.clamp(1, 1000)
      render plain: fetch_logs(lines)
    end

    def completions
      query = params[:query].to_s.strip
      completions = generate_completions(query)
      render json: completions
    end

    private

    def generate_completions(query)
      return [] if query.blank?

      results = []

      # Check if we're completing a method on something (e.g., "User.fi")
      if query.include?(".")
        parts = query.rpartition(".")
        receiver_code = parts[0]
        partial_method = parts[2]

        begin
          receiver = console_binding.eval(receiver_code)
          methods = receiver.methods.map(&:to_s)
          methods += receiver.class.instance_methods.map(&:to_s) if receiver.is_a?(Class)
          results = methods.select { |m| m.start_with?(partial_method) }.sort.first(20)
          results = results.map { |m| "#{receiver_code}.#{m}" }
        rescue
          results = []
        end
      else
        # Complete models, local variables, and common methods
        local_vars = console_binding.local_variables.map(&:to_s)
        models = ActiveRecord::Base.descendants.map(&:name) rescue []
        common = %w[puts p pp Rails.logger User]

        all = (local_vars + models + common).uniq
        results = all.select { |item| item.to_s.downcase.start_with?(query.downcase) }.sort.first(20)
      end

      results
    end

    def require_admin!
      authorize :admin, :access?
    end

    def console_binding
      @@console_bindings[current_user.id] ||= Object.new.instance_eval { binding }
    end

    def execute_code(code)
      return "" if code.blank?

      stdout = StringIO.new
      result = nil

      begin
        old_stdout = $stdout
        $stdout = stdout

        result = console_binding.eval(code) # rubocop:disable Security/Eval

        $stdout = old_stdout

        output = stdout.string
        output += "\n=> #{result.inspect}" unless result.nil?
        output
      rescue => e
        $stdout = old_stdout
        "Error: #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      end
    end

    def fetch_logs(lines)
      log_file = Rails.root.join("log", "#{Rails.env}.log")

      if File.exist?(log_file)
        `tail -n #{lines} "#{log_file}"`
      else
        "Log file not found. Logs are streaming to STDOUT.\n\nIn Coolify, view logs via the dashboard or:\n  docker logs <container_id> --tail #{lines}"
      end
    rescue => e
      "Error reading logs: #{e.message}"
    end
  end
end
