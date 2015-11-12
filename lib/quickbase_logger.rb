require "quickbase_record"
require "quickbase_logger/version"
require "quickbase_logger/logger"

module QuickbaseLogger
  def self.configure(&block)
    QuickbaseRecord.configure(&block)
  end
end
