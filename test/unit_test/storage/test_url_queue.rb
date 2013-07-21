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

class TestURLQueueHelper < Minitest::Test
  include NewsCrawler::Storage::URLQueue

  def test_normalize_url
    assert_equal('http://www.example.com',
                 URLQueue.normalize_url('www.example.com'))
    assert_equal('http://www.example.com',
                 URLQueue.normalize_url('http://www.example.com'))
    assert_equal('https://www.example.com',
                 URLQueue.normalize_url('https://www.example.com'))
  end

  def setup
    URLQueue.clear
    URLQueue.set_engine(:mongo)
    init_sample_url
  end

  def test_01_find_with_depth
    unvisited = URLQueue.find_unvisited(0)
    assert_equal 3, unvisited.count

    URLQueue.mark("test", 'http://www.test1.net', URLQueue::PROCESSING)
    URLQueue.mark("test", 'http://www.test2.net', URLQueue::PROCESSING)
    URLQueue.mark_visited('http://www.test1.net')
    URLQueue.mark_visited('http://www.test2.net')
    processing  = URLQueue.find_all('test', URLQueue::PROCESSING)
    processing_depth_0  = URLQueue.find_all('test', URLQueue::PROCESSING, 0)

    assert_equal 2, processing.count
    assert_equal 1, processing_depth_0.count
  end

  def test_02_next_unprocessed
    mark_all_url_as_visited
    url = URLQueue.mark_all('test', URLQueue::PROCESSING)
    processing_count = URLQueue.find_all('test', URLQueue::PROCESSING).count

    assert_equal 4, processing_count
  end

  def test_03_mark_all
    mark_all_url_as_visited
    before_unprocessed_count = URLQueue.find_all('test', URLQueue::UNPROCESSED).count
    before_processing_count = URLQueue.find_all('test', URLQueue::PROCESSING).count
    url = URLQueue.next_unprocessed('test')
    after_unprocessed_count = URLQueue.find_all('test', URLQueue::UNPROCESSED).count
    after_processing_count = URLQueue.find_all('test', URLQueue::PROCESSING).count

    assert_equal 1, before_unprocessed_count - after_unprocessed_count
    assert_equal 1, after_processing_count - before_processing_count
  end

  def test_04_mark_all_as_unvisited
    mark_all_url_as_visited
    URLQueue.mark_all_unvisited
    assert_equal 4, URLQueue.find_unvisited.count
  end

  def init_sample_url
    URLQueue.add('http://www.example.com')
    URLQueue.add('http://www.test1.net')
    URLQueue.add('http://www.test2.net', 'http://www.test1.net')
    URLQueue.add('http://www.test3.net')
  end

  def mark_all_url_as_visited
    URLQueue.mark_visited('http://www.example.com')
    URLQueue.mark_visited('http://www.test1.net')
    URLQueue.mark_visited('http://www.test2.net')
    URLQueue.mark_visited('http://www.test3.net')
  end
end
