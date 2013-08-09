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

#!!!
require 'news_crawler/storage/yaml_stor/yaml_stor_engine'
require 'news_crawler/storage/yaml_stor/mongo_storage'

module NewsCrawler
  module Storage
    # YAML data storage
    # You can use it for store processed data or configuration
    module YAMLStor
      class << self
        # Set YAMLStor storage engine
        # @param [ Symbol, Object ] engine specify database engine, pass an object for custom engine
        # @param [ Hash           ] opts options pass to engine
        #   This can be
        #   * `:mongo`, `:mongodb` for MongoDB backend
        def set_engine(engine, *opts)
          if engine.respond_to? :intern
            engine = engine.intern
          end
          engine_class = YAMLStorEngine.get_engines[engine]
          if engine_class
            @engine = engine_class.new(*opts)
          else
            @engine = engine
          end
        end

        # Add entry to YAML storage
        # @param [ String ] module_name
        # @param [ String ] key
        # @param [ String ] value object to serialize
        def add(module_name, key, value)
          @engine.add(module_name, key, value)
        end

        # Find document with correspond key
        # @param  [ String ]      module_name
        # @param  [ String ]      key
        # @return [ Object, nil ]
        def get(module_name, key)
          @engine.get(module_name, key)
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
