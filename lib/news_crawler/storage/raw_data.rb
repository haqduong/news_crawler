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

require 'simpleconfig'

require 'news_crawler/storage/raw_data/mongo_storage'
require 'news_crawler/storage/raw_data/raw_data_engine'

module NewsCrawler
  module Storage
    # store raw data from website
    module RawData
      class << self
        # Set RawData storage engine
        # @param [ Symbol, Object ] engine specify database engine, pass an object for custom engine
        # @param [ Hash           ] opts options pass to engine
        #   This can be
        #   * `:mongo`, `:mongodb` for MongoDB backend
        def set_engine(engine, *opts)
          if engine.respond_to? :intern
            engine = engine.intern
          end
          engine_class = RawDataEngine.get_engines[engine]
          if engine_class
            @engine = engine_class.new(*opts)
          else
            @engine = engine
          end
        end

        # Add entry to raw data collection
        # param [ String ] url
        # param [ String ] body
        def add(url, body)
          @engine.add(url, body)
        end

        # Find document with correspond url
        # @param  [ String      ] url
        # @return [ String, nil ]
        def find_by_url(url)
          @engine.find_by_url url
        end

        def count
          @engine.count
        end

        def clear
          @engine.clear
        end
      end
    end
  end
end
