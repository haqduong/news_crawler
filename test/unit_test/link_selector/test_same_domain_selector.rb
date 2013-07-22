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
require 'news_crawler/link_selector/same_domain_selector'
require 'mocha/setup'

include NewsCrawler::LinkSelector

class SameDomainSelectorTest < Minitest::Test
  def setup
    @fake_urlqueue = mock()
    @fake_urlqueue.stubs(:add)
    @fake_urlqueue.stubs(:mark)
    @fake_urlqueue.stubs(:mark_processed)
    @fake_urlqueue.stubs(:find_unvisited).returns(["http://www.example.com"])
    @fake_urlqueue.stubs(:find_all).returns(["http://www.example.com"])

    html_doc = <<HTML
<html>
<head><title></title></head>
<body>
<a href="http://www.example.com/path1">Path1</a>
<a href="http://www.example.com/path/to/file.html">File</a>
<a href="/path/to/file1.html">File1</a>
<div id="contact">
   <a href="/contactus">Contact</a>
</div>
</body>
</html>
HTML

    html_doc_1 = <<HTML
<html>
<head><title></title></head>
<body>
<a href="/path/to/file1.html">File1</a>
<div id="contact">
   <a href="/contactus">Contact</a>
</div>
</body>
</html>
HTML
    @fake_rawdata = mock()
    @fake_rawdata.stubs(:find_by_url).with('http://www.example.com').returns(html_doc)
    @fake_rawdata.stubs(:find_by_url).with('http://www.example.com/p1/').returns(html_doc_1)
    URLQueue.set_engine(@fake_urlqueue)
    RawData.set_engine(@fake_rawdata)
    @selector = SameDomainSelector.new(-1, false)
  end

  def test_extract_url
    assert_equal(["http://www.example.com/path1",
                  "http://www.example.com/path/to/file.html",
                  "http://www.example.com/path/to/file1.html",],
                 @selector.extract_url("http://www.example.com"))
    assert_equal(["http://www.example.com/path/to/file1.html"],
                 @selector.extract_url("http://www.example.com/p1/"))
  end

  def teardown
    URLQueue.set_engine(:mongo)
    RawData.set_engine(:mongo)
  end
end
