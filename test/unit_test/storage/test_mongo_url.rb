# -*- coding: utf-8 -*-
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
require 'news_crawler/storage/url_queue/mongo_storage'

class TestURLMongoStorage < Minitest::Test
  include NewsCrawler::Storage
  include NewsCrawler::Storage::URLQueue

  def setup
    @engine = URLQueue::MongoEngine.new({})
    @engine.clear
    init_sample_url
  end

  def test_order
    :sort
  end

  def test_00_reset
    @engine.clear
    assert_equal 0, @engine.all.count
  end

  def test_01_add_url
    entries = @engine.all
    assert_equal 4, entries.count
  end

  def test_02_add_duplicate_url
    assert_raises(DuplicateURLError) {
      @engine.add('http://www.example.com')
    }
  end

  def test_03_mark_module
    @engine.mark_visited('http://www.example.com')
    @engine.mark_visited('http://www.test1.net')
    @engine.mark_visited('http://www.test2.net')
    @engine.mark_visited('http://www.test3.net')

    @engine.mark("test", 'http://www.example.com', URLQueue::PROCESSED)
    processed   = @engine.find_all('test', URLQueue::PROCESSED)
    processing  = @engine.find_all('test', URLQueue::PROCESSING)
    unprocessed = @engine.find_all('test', URLQueue::UNPROCESSED)

    assert_equal 1, processed.count
    assert_equal 0, processing.count
    assert_equal 3, unprocessed.count
    assert_includes processed, 'http://www.example.com'
    assert_equal('http://www.example.com',
                 @engine.find_one('test', URLQueue::PROCESSED))
    assert_nil @engine.find_one('test1', URLQueue::PROCESSED)

    @engine.mark("test", 'http://www.test1.net', URLQueue::PROCESSING)
    @engine.mark("test", 'http://www.test2.net', URLQueue::PROCESSING)
    processed   = @engine.find_all('test', URLQueue::PROCESSED)
    processing  = @engine.find_all('test', URLQueue::PROCESSING)
    unprocessed = @engine.find_all('test', URLQueue::UNPROCESSED)

    assert_equal 1, processed.count
    assert_equal 2, processing.count
    assert_equal 1, unprocessed.count
    assert_includes processing, 'http://www.test1.net'
    assert_includes processing, 'http://www.test2.net'

    @engine.mark("test", 'http://www.test1.net', URLQueue::UNPROCESSED)
    processed   = @engine.find_all('test', URLQueue::PROCESSED)
    processing  = @engine.find_all('test', URLQueue::PROCESSING)
    unprocessed = @engine.find_all('test', URLQueue::UNPROCESSED)

    assert_equal 1, processed.count
    assert_equal 1, processing.count
    assert_equal 2, unprocessed.count
  end

  def test_04_find_with_depth
    unvisited = @engine.find_unvisited(0)
    assert_equal 3, unvisited.count

    @engine.mark("test", 'http://www.test1.net', URLQueue::PROCESSING)
    @engine.mark("test", 'http://www.test2.net', URLQueue::PROCESSING)
    @engine.mark_visited('http://www.test1.net')
    @engine.mark_visited('http://www.test2.net')
    processing  = @engine.find_all('test', URLQueue::PROCESSING)
    processing_depth_0  = @engine.find_all('test', URLQueue::PROCESSING, 0)

    assert_equal 2, processing.count
    assert_equal 1, processing_depth_0.count
  end

  def test_05_find_and_mark
    mark_all_url_as_visited
    url = @engine.find_and_mark("test")
    processed   = @engine.find_all('test', URLQueue::PROCESSED)
    processing  = @engine.find_all('test', URLQueue::PROCESSING)
    unprocessed = @engine.find_all('test', URLQueue::UNPROCESSED)

    refute_includes processed, url
    assert_includes processing, url
    refute_includes unprocessed, url

    3.times do
      @engine.find_and_mark("test")
    end
    temp = @engine.find_and_mark("test")
    assert_nil temp
  end

  # find_and_mark a.k.a next_unprocessed
  def test_06_find_and_mark_with_depth
    mark_all_url_as_visited
    urls = []
    while (url = @engine.find_and_mark('test', 0))
      urls << url
    end

    assert_equal 3, urls.count
  end

  def test_07_mark_all
    mark_all_url_as_visited
    @engine.mark_all('test', URLQueue::PROCESSED)
    processed = @engine.find_all('test', URLQueue::PROCESSED)
    assert_equal 4, processed.count

    @engine.mark_all('test', URLQueue::UNPROCESSED)
    unprocessed = @engine.find_all('test', URLQueue::UNPROCESSED)
    assert_equal 4, unprocessed.count

    @engine.mark_all('test', URLQueue::PROCESSING)
    processing = @engine.find_all('test', URLQueue::PROCESSING)
    assert_equal 4, processing.count

    @engine.mark('test', 'http://www.test1.net', URLQueue::UNPROCESSED)
    unprocessed = @engine.find_all('test', URLQueue::UNPROCESSED)
    assert_equal 1, unprocessed.count
    @engine.mark_all('test', URLQueue::PROCESSED, URLQueue::UNPROCESSED)
    processed = @engine.find_all('test', URLQueue::PROCESSED)
    assert_equal 1, processed.count
  end

  def init_sample_url
    @engine.add('http://www.example.com')
    @engine.add('http://www.test1.net')
    @engine.add('http://www.test2.net', 'http://www.test1.net')
    @engine.add('http://www.test3.net')
  end

  def mark_all_url_as_visited
    @engine.mark_visited('http://www.example.com')
    @engine.mark_visited('http://www.test1.net')
    @engine.mark_visited('http://www.test2.net')
    @engine.mark_visited('http://www.test3.net')
  end
end
