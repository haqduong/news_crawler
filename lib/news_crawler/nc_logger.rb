#! /usr/bin/env ruby
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

require 'logger'

module NewsCrawler
  class NCLogger
    # Get logger
    def self.get_logger
      @logger ||= Logger.new(STDERR)
      @logger.progname = 'news_crawler'
      @logger
    end

    # Set logger level
    # param [ Logger::Severity ] l level
    def self.set_level(l)
      get_logger.level = l
    end

    # Set logger, should same API as Ruby Logger
    # param [ Object ] l logger
    def self.set_logdev(ld)
      @logger = Logger.new(ld)
      @logger.progname = 'news_crawler'
    end
  end
end
