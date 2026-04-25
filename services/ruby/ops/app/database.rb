require "pg"

module Ops
  class Database
    def initialize(database_url)
      @database_url = database_url
    end

    def configured?
      !@database_url.nil? && !@database_url.empty?
    end

    def ready?
      return false unless configured?

      PG.connect(@database_url) do |connection|
        connection.exec("select 1")
      end

      true
    rescue PG::Error
      false
    end
  end
end
