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

require 'mongo'
require 'simple_config'
require 'news_crawler/storage/raw_data/raw_data_engine'


module NewsCrawler
  module Storage
    module RawData
      # Raw data storage implement using MongoDB
      class MongoStorage < NewsCrawler::Storage::RawData::RawDataEngine
        NAME = 'mongo'

        include Mongo

        def initialize(**opts)
          config = (SimpleConfig.for :application)
          client = MongoClient.new(config.mongodb.host, config.mongodb.port)
          db = client[config.mongodb.db_name]
          @coll = db[config.prefix + '_' + config.suffix.raw_data]
          @coll.ensure_index({:url => Mongo::ASCENDING}, {:unique => true})
        end

        # Add entry to raw data collection, overwrite old data
        # param [ String ] url
        # param [ String ] body
        def add(url, body)
          @coll.update({:url   => url},
                       {:$set  => {:body => body}},
                       {:upsert => true})
        end

        # Find document with correspond url
        # @param  [ String      ] url
        # @return [ String, nil ]
        def find_by_url(url)
          result = @coll.find_one({:url => url})
          if (!result.nil?)
            result['body']
          else
            nil
          end
        end

        # Get number of raw data entries
        def count
          @coll.count
        end

        def clear
          @coll.remove
        end
      end
    end
  end
end
