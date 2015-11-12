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