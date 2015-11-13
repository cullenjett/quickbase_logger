module QuickbaseLogger
  class Logger
    include QuickbaseRecord::Model

    attr_accessor :text_logger

    def initialize(options={})
      raise ArgumentError.new("QuickbaseLogger::Logger.new must receive a :related_script argument.") unless options[:related_script]

      @log = []
      @start = "#{formatted_date} #{formatted_time}"

      file_name = options.fetch(:file_name, 'quickbase_logger_default')
      @text_logger = ::Logger.new("#{formatted_logger_path}#{file_name}.log", "monthly") # standard ruby Logger instance
      @text_logger.info("START")
      super
    end

    def log_to_quickbase
      raise ArgumentError.new("#log_to_quickbase() must be given a block. Code run inside that block will be logged to the QuickBase application.") unless block_given?

      begin
        yield
        log_success_to_text_file
        log_success_to_quickbase
      rescue => err
        log_failure_to_text_file(err)
        log_failure_to_quickbase(err)
        raise err
      end
    end

    def info(message)
      log << "Info [#{formatted_time}]: #{message}"
    end

    def warn(message)
      log << "Warn [#{formatted_time}]: #{message}"
    end

    def error(message)
      log << "Error [#{formatted_time}]: #{message}"
    end

    private

    def log_success_to_text_file
      joined_logs = self.log.join("\n")
      text_logger.info("LOGS:\n#{joined_logs}")
      text_logger.info("END")
    end

    def log_failure_to_text_file(err)
      joined_logs = self.log.join("\n")
      text_logger.info("logs:\n#{joined_logs}")

      text_logger.error("ERROR: #{err}")
      text_logger.error("BACKTRACE:\n\t#{err.backtrace.slice(0, 7).join("\n\t")}")
    end

    def log_success_to_quickbase
      self.status = "Success"
      self.end = "#{formatted_date} #{formatted_time}"
      self.log = self.log.join("\n")

      save
    end

    def log_failure_to_quickbase(err)
      self.end = "#{formatted_date} #{formatted_time}"
      self.status = "Fail"

      self.log = self.log.join("\n")
      self.log << "\nERROR: #{err} \n"
      self.log << "BACKTRACE:\n\t#{err.backtrace.slice(0, 10).join("\n\t")}"

      save
    end

    def formatted_date
      DateTime.now.strftime("%m/%d/%Y").strip
    end

    def formatted_time
      DateTime.now.strftime("%l:%M:%S %p").strip
    end

    def formatted_logger_path
      path = QuickbaseLogger.configuration.logger_path
      path[-1] =~ /\// ? path : "#{path}/"
    end
  end
end