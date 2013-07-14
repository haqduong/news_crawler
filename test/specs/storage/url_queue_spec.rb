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

require_relative './storage_spec_test_helper.rb'

require 'news_crawler/storage/url_queue'
require 'set'

include NewsCrawler::Storage

describe URLQueue do
  before do
    URLQueue.set_engine(:mongo)
    URLQueue.clear
    URLQueue.add("www.example.com")
    URLQueue.add("www.example1.net")
    URLQueue.add("www.example1.net/path1", 'www.example1.net')
  end

  it 'should add url succesfully' do
    URLQueue.all.count.must_equal(3)
  end

  it 'should mark only url visited' do
    URLQueue.mark_visited "www.example.com"
    unvisited = URLQueue.find_unvisited
    refute_includes unvisited, "http://www.example.com"
    assert_includes unvisited, "http://www.example1.net"
  end

  it 'should mark arbitrary module succesfully' do
    URLQueue.mark(:test_mod, 'www.example.com', URLQueue::PROCESSED)
    URLQueue.mark_visited("www.example.com")
    URLQueue.mark_visited("www.example1.net")
    URLQueue.mark_visited("www.example1.net/path1")
    processed = URLQueue.find_all(:test_mod, URLQueue::PROCESSED)
    processing = URLQueue.find_all(:test_mod, URLQueue::PROCESSING)
    unprocessed = URLQueue.find_all(:test_mod, URLQueue::UNPROCESSED)

    assert_equal(Set.new(['http://www.example.com']),
                 Set.new(processed))
    assert_equal [], processing
    assert_equal(Set.new(['http://www.example1.net',
                          'http://www.example1.net/path1']),
                 Set.new(unprocessed))
    assert_nil URLQueue.find_one(:test_mod, URLQueue::PROCESSING)
    refute_nil URLQueue.find_one(:test_mod, URLQueue::PROCESSED)
  end

  after do
    URLQueue.clear
  end
end
