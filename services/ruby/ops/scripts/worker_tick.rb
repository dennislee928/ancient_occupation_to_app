require "logger"

require_relative "../app/config"
require_relative "../app/database"

config = Ops::Config.new
logger = Logger.new($stdout)
database = Ops::Database.new(config.database_url)

if database.ready?
  logger.info("ruby-ops worker heartbeat ok")
else
  logger.warn("ruby-ops worker heartbeat skipped: database not ready")
end
