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
require 'news_crawler/storage/url_queue/mongo_storage'
require 'news_crawler/storage/url_queue/url_queue_engine'

module NewsCrawler
  module Storage
    # Store and manipulate url queue
    module URLQueue
      ACTION_LIST = [:mark_visited, :mark_processed, :find_unvisited,
                     :find_unprocessed, :find_unprocessed_with_depth]
      PROCESSED   = 'processed'
      PROCESSING  = 'processing'
      UNPROCESSED = 'unprocessed'

      class << self
        # Set URLQueue storage engine
        # @param [ Symbol, Object ] engine specify database engine, pass an object for custom engine
        # @param [ Hash           ] opts options pass to engine
        #   This can be
        #   * `:mongo`, `:mongodb` for MongoDB backend
        def set_engine(engine, **opts)
          if engine.respond_to? :intern
            engine = engine.intern
          end
          engine_class = URLQueueEngine.get_engines[engine]
          if engine_class
            @engine = engine_class.new(**opts)
          else
            @engine = engine
          end
        end

        # delegate request to the engine
        def method_missing(name, url = '', **opts)
          if ACTION_LIST.include? name
            if url.size == 0
              @engine.send(name, opts)
            else
              url = normalize_url url
              @engine.send(name, url, opts)
            end
          end
        end

        # Set processing state of url in given module
        # @param [ String ] module_name
        # @param [ String ] url
        # @param [ String ] state one of unprocessed, processing, processed
        def mark(module_name, url, state)
          url = normalize_url url
          @engine.mark(module_name, url, state)
        end

        # Mark all url to state
        # @param [ String ] module_name
        # @param [ String ] new_state   new state
        # @param [ String ] orig_state  original state
        def mark_all(module_name, new_state, orig_state = nil)
          @engine.mark_all(module_name, new_state, orig_state)
        end

        # Find all visited urls with module's state
        # @param  [ String ] module_name
        # @param  [ String ] state
        # @param  [ Fixnum ] max_depth max url depth return (inclusive)
        # @return [ Array  ] URL list
        def find_all(module_name, state, max_depth = -1)
          @engine.find_all(module_name, state, max_depth)
        end

        # Find one visited url with given module process state
        # @param  [ String      ] module_name
        # @param  [ String      ] state one of unprocessed, processing, processed
        # @param  [ Fixnum      ] max_depth max url depth return (inclusive)
        # @return [ String, nil ] URL
        def find_one(module_name, state, max_depth = -1)
          @engine.find_one(module_name, state, max_depth)
        end

        # Get next unprocessed a url and mark it as processing in atomic
        # @param  [ String      ] module_name
        # @param  [ Fixnum      ] max_depth max url depth return (inclusive)
        # @return [ String, nil ] URL or nil if url doesn't exists
        def next_unprocessed(module_name, max_depth = -1)
          @engine.next_unprocessed(module_name, max_depth)
        end

        # Get list of unvisited URL
        # @param  [ Fixnum ] max_depth maximum depth of url return
        # @return [ Array  ] unvisited url with maximum depth (option)
        def find_unvisited(max_depth = -1)
          @engine.find_unvisited(max_depth)
        end

        # Add URL to queue
        # @param [ String ] url
        # @param [ String ] ref_url reference url
        def add(url, ref_url = '')
          url = normalize_url url
          if ref_url != ''
            ref_url = normalize_url ref_url
          end
          @engine.add(url, ref_url)
        end

        # Clear URLQueue
        # @return [ Fixnum ] number of urls removed
        def clear
          @engine.clear
        end

        # Get all url with status
        # @return [ Array ] URL list
        def all
          @engine.all
        end

        def normalize_url(url)
          if (!url.start_with? "http")
            "http://" + url
          else
            url
          end
        end
      end
    end
  end
end
