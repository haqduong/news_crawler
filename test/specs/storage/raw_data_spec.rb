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

require_relative './storage_spec_test_helper.rb'

require 'news_crawler/storage/raw_data/mongo_storage'

include Mongo
include NewsCrawler::Storage::RawData

describe MongoStorage do
  before do
    RawData.set_engine(:mongo)
  end

  it 'should add one entry into database succesfully' do
    url = 'http://www.example.com'
    body = '<html><head></head><body></body></html>'
    RawData.add(url, body)
    RawData.count.must_equal 1
    assert_equal body, RawData.find_by_url(url)
  end

  it 'should return nil if url is unvisited' do
    assert_nil RawData.find_by_url('does_not_existed_url')
  end

  after do
    RawData.clear
  end
end
