require 'spec_helper'
require 'yaml'

creds = YAML.load_file("spec/config.yml")

RSpec.describe QuickbaseLogger do
  describe '.configure' do
    it "passes it's block to QuickbaseRecord.configure()" do
      expect(QuickbaseRecord).to receive(:configure)
      QuickbaseLogger.configure do |config|
        config.realm = "ais"
        config.username = creds["username"]
        config.password = creds["password"]
      end
    end
  end
end


RSpec.describe QuickbaseLogger::Logger do
  describe '.initialize' do
    it "defines a parent script that all log records will be related to" do
      logger = QuickbaseLogger::Logger.new(related_script: 123)
      expect(logger.related_script).to eq(123)
    end
  end

  describe '#log_to_quickbase' do
    it "calls #save to create a new record in QuickBase" do
      qb_logger = QuickbaseLogger::Logger.new(related_script: 1)

      expect(qb_logger).to receive(:save)

      qb_logger.log_to_quickbase do
        qb_logger.info('Hello, world!')
        qb_logger.warn('Danger ahead...')
        qb_logger.error('OH NO!!!')
      end
    end
  end
end