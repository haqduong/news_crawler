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

require 'news_crawler/storage/yaml_stor'
# require 'news_crawler/storage/yaml_stor/yaml_stor_error'
require 'news_crawler/storage/yaml_stor/mongo_storage'

class TestYAMLStorMongo < Minitest::Test
  include NewsCrawler::Storage
  include NewsCrawler::Storage::YAMLStor

  def setup
    @engine = YAMLStor::MongoStorage.new({})
    @engine.clear
    init_sample_data
  end

  def test_order
    :sort
  end

  def test_00_reset
    @engine.clear
    assert_equal 0, @engine.count
  end

  def test_01_add_entries
    assert_equal 3, @engine.count
    h3 = {:c => 1, :b => 2}
    @engine.add('mod3', 'conf', h3)
    assert_equal 4, @engine.count
    rh = @engine.get('mod3', 'conf')
    assert_equal rh, h3
  end

  def test_02_update_entry
    h3 = {:c => 1, :b => 2}
    @engine.add('mod1', 'conf', h3)
    rh = @engine.get('mod1', 'conf')
    assert_equal rh, h3
  end


  def init_sample_data
    @h1 = {:a => 1, :b => 2}
    @h2 = {:a => 3, :b => 2}
    @engine.add('mod1', 'conf', @h1)
    @engine.add('mod1', 'data', @h1)
    @engine.add('mod2', 'conf', @h2)
  end
end
