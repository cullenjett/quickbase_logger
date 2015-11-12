require 'quickbase_record'

module QuickbaseLogger
  class Logger
    include QuickbaseRecord::Model

    attr_accessor :text_logger

    define_fields do |t|
      t.dbid 'bj4g2kf3k'
      t.number :id, 3, :primary_key, :read_only
      t.number :related_script, 6
      t.date :start, 9
      t.date :end, 10
      t.string :log, 11
      t.string :status, 12
    end

    def initialize(options={})
      @related_script = options[:related_script]
      @log = []
      @start = "#{formatted_date} #{formatted_time}"

      file_name = options.fetch(:file_name, 'quickbase_logger_default')
      @text_logger = Logger.new("./spec/log/#{file_name}.log", "monthly")
      @text_logger.info("START")
      super
    end

    def log_to_quickbase
      raise ArgumentError.new(".log_to_quickbase() must be given a block. Code run inside that block will be logged to the QuickBase application.") if !block_given?

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
      text_logger.info("\n#{joined_logs}")
      text_logger.info("END")
      text_logger.info("")
    end

    def log_failure_to_text_file(err)
      joined_logs = self.log.join("\n")
      text_logger.info("\n#{joined_logs}")

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
  end
end