require "json"
require "time"
require "webrick"

require_relative "config"
require_relative "database"

module Ops
  class Server
    def initialize(config: Config.new)
      @config = config
      @database = Database.new(config.database_url)
      @started_at = Time.now.utc
    end

    def start
      server = WEBrick::HTTPServer.new(
        BindAddress: "0.0.0.0",
        Port: @config.port.to_i,
        AccessLog: [],
        Logger: WEBrick::Log.new($stdout, WEBrick::Log::INFO)
      )

      server.mount_proc("/healthz") do |_req, res|
        write_json(
          res,
          200,
          service: "ruby-ops",
          status: "ok",
          environment: @config.app_env,
          uptime_sec: (Time.now.utc - @started_at).to_i
        )
      end

      server.mount_proc("/readyz") do |_req, res|
        if @database.ready?
          write_json(res, 200, service: "ruby-ops", status: "ready")
        else
          write_json(
            res,
            503,
            service: "ruby-ops",
            status: "not_ready",
            reason: readiness_reason
          )
        end
      end

      trap_signals(server)
      server.start
    end

    private

    def trap_signals(server)
      %w[INT TERM].each do |signal|
        Signal.trap(signal) { server.shutdown }
      end
    end

    def readiness_reason
      return "SUPABASE_DATABASE_URL is not configured" unless @database.configured?

      "database ping failed"
    end

    def write_json(response, status, payload)
      response.status = status
      response["Content-Type"] = "application/json"
      response.body = JSON.generate(payload)
    end
  end
end

Ops::Server.new.start if $PROGRAM_NAME == __FILE__
