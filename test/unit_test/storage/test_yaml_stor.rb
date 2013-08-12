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
require 'news_crawler/storage/yaml_stor/yaml_stor_engine'

class TestYAMLStor < Minitest::Test
#  include NewsCrawler::Storage
  include NewsCrawler::Storage::YAMLStor

  def setup
    YAMLStor.set_engine(:mongo)
    YAMLStor.clear
    init_sample_data
  end

  def test_order
    :sort
  end

  def test_00_reset
    YAMLStor.clear
    assert_equal 0, YAMLStor.count
  end

  def test_01_add_entries
    assert_equal 3, YAMLStor.count
    h3 = {:c => 1, :b => 2}
    YAMLStor.add('mod3', 'conf', h3)
    assert_equal 4, YAMLStor.count
    rh = YAMLStor.get('mod3', 'conf')
    assert_equal rh, h3
  end

  def test_02_update_entry
    h3 = {:c => 1, :b => 2}
    YAMLStor.add('mod1', 'conf', h3)
    rh = YAMLStor.get('mod1', 'conf')
    assert_equal rh, h3
  end


  def init_sample_data
    @h1 = {:a => 1, :b => 2}
    @h2 = {:a => 3, :b => 2}
    YAMLStor.add('mod1', 'conf', @h1)
    YAMLStor.add('mod1', 'data', @h1)
    YAMLStor.add('mod2', 'conf', @h2)
  end
end
