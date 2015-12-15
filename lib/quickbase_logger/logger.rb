module QuickbaseLogger
  class Logger
    include QuickbaseRecord::Model

    attr_accessor :text_logger, :purge_frequency

    def initialize(options={})
      raise ArgumentError.new("QuickbaseLogger::Logger.new must receive a :related_script argument.") unless options[:related_script]

      @log = []
      @start = "#{formatted_date} #{formatted_time}"
      @purge_frequency = options.fetch(:purge_frequency, 180)

      file_name = options.fetch(:file_name, 'quickbase_logger_default')
      @text_logger = ::Logger.new("#{formatted_logger_path}#{file_name}.log", "monthly") # standard ruby Logger instance
      @text_logger.info("START")

      super(options)
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

      purge_logs
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

    def purge_logs
      purge_date = Date.today - purge_frequency.days
      purge_date = purge_date.strftime("%m/%d/%Y")

      qb_client.purge_records(self.class.dbid, {query: "{1.OBF.#{purge_date}}"})
    end

    private

    def log_success_to_text_file
      joined_logs = self.log.join("\n")
      text_logger.info("LOGS:\n#{joined_logs}")
      text_logger.info("END")
      text_logger.info("")
    end

    def log_failure_to_text_file(err)
      joined_logs = self.log.join("\n")
      text_logger.info("LOGS:\n#{joined_logs}")

      text_logger.error("ERROR: #{err}")
      text_logger.error("BACKTRACE:\n\t#{err.backtrace.slice(0, 10).join("\n\t")}")
      text_logger.info("END")
      text_logger.info("")
    end

    def log_success_to_quickbase
      self.status = "Success"
      self.end = "#{formatted_date} #{formatted_time}"
      self.log = self.log.join("\n")

      begin
        save
      rescue StandardError => err
        text_logger.error("-- COULD NOT WRITE SUCCESS TO QUICKBASE --")
        text_logger.error(err)
        text_logger.error("BACKTRACE:\n\t#{err.backtrace.slice(0, 10).join("\n\t")}")
        raise err
      end
    end

    def log_failure_to_quickbase(err)
      self.end = "#{formatted_date} #{formatted_time}"
      self.status = "Failure"

      self.log = self.log.join("\n")
      self.log << "\nERROR: #{err} \n"
      self.log << "BACKTRACE:\n\t#{err.backtrace.slice(0, 10).join("\n\t")}"

      begin
        save
      rescue StandardError => err
        text_logger.error("-- COULD NOT WRITE FAILURE TO QUICKBASE --")
        text_logger.error(err)
        text_logger.error("BACKTRACE:\n\t#{err.backtrace.slice(0, 10).join("\n\t")}")
        raise err
      end
    end

    def formatted_date
      DateTime.now.strftime("%m/%d/%Y").strip
    end

    def formatted_time
      DateTime.now.strftime("%l:%M:%S %p").strip
    end

    def formatted_logger_path
      path = QuickbaseLogger.configuration.logger_path || "/log"
      path[-1] =~ /\// ? path : "#{path}/"
    end
  end
end