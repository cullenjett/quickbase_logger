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

    it "sets a default purge_frequency of 180 days" do
      logger = QuickbaseLogger::Logger.new(related_script: 123)
      expect(logger.purge_frequency).to eq(180)
    end
  end

  describe '#log_to_quickbase' do
    it "calls #save to create a new record in QuickBase" do
      qb_logger = QuickbaseLogger::Logger.new(related_script: 1)

      expect(qb_logger).to receive(:save)

      qb_logger.log_to_quickbase do
        qb_logger.info('testing that #save is called')
      end
    end

    it "deletes records older than the purge frequency" do
      qb_logger = QuickbaseLogger::Logger.new(related_script: 1, purge_frequency: 0)
      purge_date = Date.today.strftime("%m/%d/%Y")

      # the query "{10.EX.1}AND{1.OBF.#{purge_date}}" uses the FID for related_script and date_created, respectively
      expect_any_instance_of(AdvantageQuickbase::API).to receive(:purge_records).with('bkd86zn87', {query: "{10.EX.1}AND{1.OBF.#{purge_date}}"})

      qb_logger.log_to_quickbase do
        qb_logger.info('testing that #purge_records is called')
      end
    end
  end
end