require_relative './unit_test_helper.rb'

require 'news_crawler/nc_logger'
require 'mocha/setup'

include NewsCrawler

class NCLoggerTest < Minitest::Test
  def test_get_logger
    logger = NCLogger.get_logger
    refute_nil logger
    assert_equal 'news_crawler', logger.progname
  end

  def test_set_level
    NCLogger.set_level(Logger::ERROR)
    logger = NCLogger.get_logger
    assert_equal Logger::ERROR, logger.level
  end

  def test_set_logdev
    File.open('/dev/null', 'w') do | io |
      io.expects(:write)
      NCLogger.set_logdev(io)
      NCLogger.get_logger.info("Test info")
      assert_equal 'news_crawler', NCLogger.get_logger.progname
    end
  end
end
