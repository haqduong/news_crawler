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

# TODO implement easy API

require 'news_crawler/autostart'
require 'news_crawler/config'
require 'news_crawler/downloader'
require 'news_crawler/link_selector/same_domain_selector'

NewsCrawler::Storage::RawData.set_engine(:mongo)
NewsCrawler::Storage::URLQueue.set_engine(:mongo)

include NewsCrawler::Storage

URLQueue.clear

# RawData.clear
# dwl = NewsCrawler::Downloader.new
# dwl.run
# #dwl.async.run
# #dwl.graceful_terminate

URLQueue.mark_all('NewsCrawler::LinkSelector::SameDomainSelector', "unprocessed")

puts "Raw entries: #{RawData.count}"
NewsCrawler::LinkSelector::SameDomainSelector.new
puts "URL entries: #{URLQueue.count}"
