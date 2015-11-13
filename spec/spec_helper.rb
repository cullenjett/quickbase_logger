require 'quickbase_record'
require 'quickbase_logger'
require 'yaml'

creds = YAML.load_file("spec/config.yml")

QuickbaseLogger.configure do |config|
  config.realm = "ais"
  config.username = creds["username"]
  config.password = creds["password"]
end

QuickbaseLogger::Logger.define_fields do |t|
  t.dbid 'bkd86zn87'
  t.number :id, 3, :primary_key, :read_only
  t.date :start, 6
  t.date :end, 7
  t.string :log, 8
  t.string :status, 9
  t.number :related_script, 10
end

QuickbaseLogger::Logger.LOGGER_PATH = "./spec/log"