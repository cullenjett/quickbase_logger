module QuickbaseLogger
  class Configuration
    attr_accessor :realm, :username, :password, :token, :usertoken, :logger_path, :fields_definition

    def initialize
    end

    def define_fields(&block)
      self.fields_definition = block
    end
  end
end