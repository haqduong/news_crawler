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

require_relative './unit_test_helper.rb'

require 'news_crawler/url_helper'

class TestURLHelper < Minitest::Test
  include NewsCrawler::URLHelper

  def setup
  end

  def test_urls_equal_case
    assert_equal(true,
                 same_domain?('www.example.com',
                              'www.example.com'))
    assert_equal(true,
                 same_domain?('example.com',
                              'www.example.com'))

    assert_equal(true,
                 same_domain?('www.example.com/ababa',
                              'www.example.com'))

    assert_equal(true,
                 same_domain?('www.example.com',
                              'example.com/aba'))

    assert_equal(true,
                 same_domain?('http://www.example.com',
                              'www.example.com'))
    assert_equal(true,
                 same_domain?('www.example.com',
                              'http://www.example.com/aba'))
  end

  def test_urls_unequal_case
    assert_equal(false,
                 same_domain?('www.example.net',
                              'www.example.com'))
    assert_equal(false,
                 same_domain?('example.com',
                              'www.example.net'))

    assert_equal(false,
                 same_domain?('www.example.com/ababa',
                              'www.example.net/ababa'))

    assert_equal(false,
                 same_domain?('www.example.co',
                              'example.com/aba'))

    assert_equal(false,
                 same_domain?('http://www.example.com',
                              'www.example.co'))
    assert_equal(false,
                 same_domain?('www.example',
                              'http://www.example.com/aba'))
  end

  def test_same_domain_abs_path
    assert_equal(true,
                 same_domain?('/', 'http://www.example.com'))
    assert_equal(true,
                 same_domain?('/path/path', 'http://www.example.com'))
    assert_equal(true,
                 same_domain?('/path/path', '/'))
  end

  def test_url_path_full_part
    p = get_url_parts('http://www.example.com/p1/p2')
    assert_equal p[:scheme], 'http'
    assert_equal p[:domain], 'www.example.com'
    assert_equal p[:path], '/p1/p2'
  end

  def test_url_only_domain
    p = get_url_parts('www.example.com/')
    assert_nil p[:scheme]
    assert_equal p[:domain], 'www.example.com'
    assert_equal p[:path], '/'

    p = get_url_parts('www.example.com')
    assert_nil p[:scheme]
    assert_equal p[:domain], 'www.example.com'
    assert_nil p[:path]
  end

  def test_url_only_path
    p = get_url_parts('/')
    assert_nil p[:scheme]
    assert_nil p[:domain]
    assert_equal p[:path], '/'

    p = get_url_parts('/ab/aba')
    assert_nil p[:scheme]
    assert_nil p[:domain]
    assert_equal p[:path], '/ab/aba'
  end
end
