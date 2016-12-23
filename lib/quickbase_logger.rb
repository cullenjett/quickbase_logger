require "quickbase_record"
require "quickbase_logger/version"
require "quickbase_logger/logger"
require "quickbase_logger/configuration"

module QuickbaseLogger
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration

    QuickbaseRecord.configure do |config|
      config.realm = configuration.realm
      config.token = configuration.token

      if configuration.username
        config.username = configuration.username
        config.password = configuration.password
      else
        config.usertoken = configuration.usertoken
      end
    end

    Logger.define_fields(&configuration.fields_definition)
  end
end
