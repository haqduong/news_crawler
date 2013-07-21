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
    module URLQueue
      # Basic class for URLQueue engine.
      # Subclass and implement all its method to create new URLQueue engine,
      # you should keep methods' singature unchanged
      class URLQueueEngine
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

        # Set processing state of url in given module
        # @param [ String ] module_name
        # @param [ String ] url
        # @param [ String ] state one of unprocessed, processing, processed
        def mark(module_name, url, state)
          raise NotImplementedError
        end

        # Change all url in an state to other state
        # @param [ String ] module_name
        # @param [ String ] new_state   new state
        # @param [ String ] orig_state  original state
        def mark_all(module_name, new_state, orig_state = nil)
          raise NotImplementedError
        end

        # Produce next unprocessed url and mark it as processing
        # @param  [ String      ] module_name
        # @return [ String, nil ]
        def next_unprocessed(module_name)
          raise NotImplementedError
        end

        # Find all visited urls with module's state
        # @param  [ String ] module_name
        # @param  [ String ] state
        # @param  [ Fixnum ] max_depth max url depth return (inclusive)
        # @return [ Array  ] URL list
        def find_all(module_name, state, max_depth = -1)
          raise NotImplementedError
        end

        # Find one visited url with given module process state
        # @param  [ String      ] module_name
        # @param  [ String      ] state one of unprocessed, processing, processed
        # @param  [ Fixnum      ] max_depth max url depth return (inclusive)
        # @return [ String, nil ] URL
        def find_one(module_name, state, max_depth = -1)
          raise NotImplementedError
        end

        # Get list of unvisited URL
        # @param  [ Fixnum ] max_depth maximum depth of url return
        # @return [ Array  ] unvisited url with maximum depth (option)
        def find_unvisited(max_depth = -1)
          raise NotImplementedError
        end

        # Add url with reference url
        # @param [ String ] url URL
        # @param [ String ] ref_url reference URL
        def add(url, ref_url = '')
          raise NotImplementedError
        end

        # Clear URLQueue
        # @return [ Fixnum ] number of urls removed
        def clear
          raise NotImplementedError
        end

        # Mark an URL as visited
        # @param [ String ] url
        def mark_visited(url)
          raise NotImplementedError
        end

        # Mark all URLs as unvisited
        def mark_all_unvisited
          raise NotImplementedError
        end

        # Get all url with status
        # @return [ Array ] URL list
        def all
          raise NotImplementedError
        end
      end
    end
  end
end
