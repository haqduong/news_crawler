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

require 'simple_config'

SimpleConfig.for :application do
  group :db do
    set :engine, :mongo
  end

  group :mongodb do
    set :host, 'localhost'
    set :port, '27017'
    set :db_name, 'news_crawler-test'
  end

  group :suffix do
    set :raw_data, 'raw_data'
    set :url_queue, 'url_queue'
  end

  set :prefix, ''
end

SimpleConfig.for :same_domain_selector do
  group :exclude do
    set 'vnexpress.net', ['ban-doc', 'tam-su', 'cuoi', 'rss', 'anh',
                         'ban-doc-viet', 'contactus', 'block', 'raovat', 'video']
    set 'example.com', ['contactus']
  end
end
