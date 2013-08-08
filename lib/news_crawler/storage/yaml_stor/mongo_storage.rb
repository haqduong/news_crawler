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

require 'mongo'
require 'simple_config'
require 'news_crawler/storage/yaml_stor/yaml_stor_engine'
require 'news_crawler/nc_logger'


module NewsCrawler
  module Storage
    module YAMLStor
      # YAML storage implement using MongoDB
      class MongoStorage < NewsCrawler::Storage::YAMLStor::YAMLStorEngine
        NAME = 'mongo'

        include Mongo

        def initialize(*opts)
          config = (SimpleConfig.for :application)
          client = MongoClient.new(config.mongodb.host, config.mongodb.port)
          db = client[config.mongodb.db_name]
          @coll = db[config.prefix + '_' + config.suffix.yaml]
          # @coll.ensure_index({:key => Mongo::ASCENDING}, {:unique => true})
        end

        # Add entry to yaml collection, overwrite old data
        # @param [ String ] module_name
        # @param [ String ] key
        # @param [ String ] value YAML string
        def add(module_name, key, value)
          value.encode!('utf-8', :invalid => :replace, :undef => :replace)
          @coll.update({:key   => key,
                         :m_name => module_name},
                       {:$set  => {:value => value}},
                       {:upsert => true})
        end

        # Find document with correspond key
        # @param  [ String ] module_name
        # @param  [ String      ] key
        # @return [ String, nil ]
        def get(module_name, key)
          result = @coll.find_one({:key => key,
                                    :m_name => module_name})
          if (!result.nil?)
            result['value']
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
