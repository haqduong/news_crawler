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

require_relative './test_helper.rb'

require 'news_crawler/link_selector/same_domain_selector.rb'

include NewsCrawler::LinkSelector

describe SameDomainSelector do
  before do
    # => nothing now
  end

  it 'should return true if url in exclude list' do
    assert_equal SameDomainSelector.exclude?('http://example.net/ban-doc'), true
    assert_equal SameDomainSelector.exclude?('http://example.net/ban-doc/anh'), true
    assert_equal SameDomainSelector.exclude?('http://www.example.net/ban-doc/anh'), true
    assert_equal SameDomainSelector.exclude?('http://www.example.net/block/anh'), true
    assert_equal SameDomainSelector.exclude?('http://m.example.net/block/anh'), true
    assert_equal SameDomainSelector.exclude?('http://example.net/block/anhcuoi'), true
  end

  it 'should return false if url not in exclude list' do
    assert_equal SameDomainSelector.exclude?('http://example.net/'), false
    assert_equal SameDomainSelector.exclude?('http://example.net/tin-tuc'), false
    assert_equal SameDomainSelector.exclude?('http://www.example.net/tin-tuc'), false
    assert_equal SameDomainSelector.exclude?('http://www.example.org'), false
  end
end
