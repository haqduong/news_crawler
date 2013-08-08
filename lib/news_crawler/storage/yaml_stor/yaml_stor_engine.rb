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

module NewsCrawler
  module Storage
    module YAMLStor
      # Basic class for YAMLStor engine.
      # Subclass and implement all its method to create new YAMLStor engine,
      # you should keep methods' singature unchanged
      class YAMLStorEngine
        def self.inherited(klass)
          @engine_list = (@engine_list || []) + [klass]
        end

        # Get engine list
        # @return [ Array ] list of url queue engines
        def self.get_engines
          @engine_list = @engine_list || []
          @engine_list.inject({}) do | memo, klass |
            memo[klass::NAME.intern] = klass
            memo
          end
        end

        # Add entry to raw data collection
        # @param [ String ] module_name
        # @param [ String ] key
        # @param [ String ] value
        def add(module_name, key, value)
          raise NotImplementedError
        end

        # Get entry to raw data collection
        # @param [ String ] module_name
        # @param [ String ] key
        # @return [ String, nil ] Value or nil if key isn't found
        def get(module_name, key)
          raise NotImplementedError
        end

        def count
          raise NotImplementedError
        end

        def clear
          raise NotImplementedError
        end
      end
    end
  end
end
