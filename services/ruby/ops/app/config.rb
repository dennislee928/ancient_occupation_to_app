module Ops
  class Config
    attr_reader :app_env, :port, :log_level, :database_url

    def initialize(env = ENV)
      @app_env = fetch(env, "APP_ENV", "development")
      @port = fetch(env, "OPS_PORT", "9292")
      @log_level = fetch(env, "LOG_LEVEL", "info")
      @database_url = env["SUPABASE_DATABASE_URL"]
    end

    private

    def fetch(env, key, fallback)
      value = env[key]
      value.nil? || value.empty? ? fallback : value
    end
  end
end
