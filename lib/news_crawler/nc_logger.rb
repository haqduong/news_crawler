require 'logger'

module NewsCrawler
  class NCLogger
    # Get logger
    def self.get_logger
      @logger ||= Logger.new(STDERR)
      @logger.progname = 'news_crawler'
      @logger
    end

    # Set logger level
    # param [ Logger::Severity ] l level
    def self.set_level(l)
      get_logger.level = l
    end

    # Set logger, should same API as Ruby Logger
    # param [ Object ] l logger
    def self.set_logdev(ld)
      @logger = Logger.new(ld)
      @logger.progname = 'news_crawler'
    end
  end
end
