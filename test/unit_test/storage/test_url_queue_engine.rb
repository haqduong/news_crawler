#--
# NewsCrawler - a website crawler
#
# Copyright (C) 2013 - Hà Quang Dương <contact@haqduong.net>
#
# This file is part of NewsCrawler.
#
# NewsCrawler is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# NewsCrawler is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NewsCrawler.  If not, see <http://www.gnu.org/licenses/>.
#++

require_relative './storage_test_helper.rb'

require 'news_crawler/storage/url_queue'
require 'news_crawler/storage/url_queue/url_queue_error'
require 'news_crawler/storage/url_queue/url_queue_engine'

include NewsCrawler::Storage::URLQueue

class FooURLQueueEngine < URLQueueEngine
  NAME = 'foo'
end

class TestURLQueueEngine < MiniTest::Test
  def test_fooengine_should_present
    refute_nil URLQueueEngine.get_engines[:foo]
  end
end
