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
require 'news_crawler/storage/url_queue/url_queue_error'
require 'news_crawler/storage/url_queue/url_queue_engine'

module NewsCrawler
  module Storage
    module URLQueue
      # List storage engine with MongoDB backend
      class MongoEngine < NewsCrawler::Storage::URLQueue::URLQueueEngine
        NAME = 'mongo'

        require 'mongo'
        include Mongo

        # Construct a queue
        def initialize(*opts)
          config = SimpleConfig.for :application
          db = MongoClient.new(config.mongodb.host, config.mongodb.port,
                               pool_size: 4,
                               pool_timeout: 5)[config.mongodb.db_name]
          coll_name = config.prefix + '_' + config.suffix.url_queue
          h_opts = ((opts[-1].is_a? Hash) ? opts[-1] : {})
          @coll = db[h_opts[:coll_name] || coll_name]
          @coll.ensure_index({:url => Mongo::ASCENDING}, {:unique => true})
        end

        # Add an URL to list with reference URL
        # @param [ String ] url
        # @param [ String ] ref_url
        def add(url, ref_url = '')
          if (ref_url == '')
            depth = 0
          else
            depth = (get_url_depth(ref_url) || 0) + 1
          end
          begin
            @coll.insert({:url        => url,
                           :depth     => depth,
                           :visited   => false})
          rescue Mongo::OperationFailure => e
            if e.error_code == 11000  # duplicate key error
              raise DuplicateURLError, url
            else
              raise e
            end
          end
        end

        # Mark an URL as visited
        # @param [ String ] url
        def mark_visited(url)
          @coll.update({:url  => url},
                       {:$set => {:visited => true}})
        end

        # # Mark an URL as processed
        # # @param [ String ] url
        # def mark_processed(url, **opts)
        #   @coll.update({:url  => url},
        #                {:$set => {:processed => true}})
        # end

        # Set processing state of url in given module
        # @param [ String ] module_name
        # @param [ String ] url
        # @param [ String ] state one of unprocessed, processing, processed
        def mark(module_name, url, state)
          @coll.update({:url  => url},
                       {:$set => {module_name => state}})
        end

        # Change all url in an state to other state
        # @param [ String ] module_name
        # @param [ String ] new_state   new state
        # @param [ String ] orig_state  original state
        def mark_all(module_name, new_state, orig_state = nil)
          selector = (orig_state.nil? ? {} : {module_name => orig_state})
          @coll.update(selector,
                       {:$set => {module_name => new_state}},
                       :multi => true)
        end

        # Get all URL and status
        # @return [ Array ] array of hash contains url and status
        def all(*opts)
          @coll.find.collect do | entry |
            entry.each_key.inject({}) do | memo, key |
              if key != '_id'
                memo[key.intern] = entry[key]
              end
              memo
            end
          end
        end

        # TODO fix bug - find *visited* url
        # Find all visited urls with given module process state
        # @param  [ String ] modul_name
        # @param  [ String ] state one of unprocessed, processing, processed
        # @param  [ Fixnum ] max_depth max url depth return (inclusive)
        # @return [ Array  ] URL list
        def find_all(modul_name, state, max_depth = -1)
          if (state == URLQueue::UNPROCESSED)
            selector = {:$or => [{modul_name => state},
                                 {modul_name => {:$exists => false}}]}
          else
            selector = {modul_name => state}
          end
          selector = {:$and => [selector,
                                {'visited' => true}]}
          if max_depth > -1
            selector[:$and] << {'depth' => {:$lte => max_depth}}
          end
          @coll.find(selector).collect do | entry |
            entry['url']
          end
        end

        # Find one visited url with given module process state
        # @param  [ String      ] modul_name
        # @param  [ String      ] state one of unprocessed, processing, processed
        # @param  [ Fixnum      ] max_depth max url depth return (inclusive)
        # @return [ String, nil ] URL or nil if cann't found url matches criterial
        def find_one(modul_name, state, max_depth = -1)
          a = find_all(modul_name, state, max_depth)
          if a.size > 0
            a[0]
          else
            nil
          end
        end

        # Get next unprocessed a url and mark it as processing in atomic
        # @param  [ String      ] modul_name
        # @param  [ Fixnum      ] max_depth max url depth return (inclusive)
        # @return [ String, nil ] URL or nil if url doesn't exists
        def next_unprocessed(modul_name, max_depth = -1)
          selector = {:$or => [{modul_name => URLQueue::UNPROCESSED},
                               {modul_name => {:$exists => false}}]}
          selector = {:$and => [selector,
                                {'visited' => true}]}
          if max_depth > -1
            selector[:$and] << {'depth' => {:$lte => max_depth}}
          end
          doc = @coll.find_and_modify(:query => selector,
                                      :update => {:$set =>
                                        {modul_name => URLQueue::PROCESSING}})
          if doc.nil?
            nil
          else
            doc['url']
          end
          (doc.nil? ? nil : doc['url'])
        end
        alias :find_and_mark :next_unprocessed

        # Get list of unvisited URL
        # @param  [ Fixnum ] max_depth maximum depth of url return
        # @return [ Array  ] unvisited url with maximum depth (option)
        def find_unvisited(max_depth = -1)
          if max_depth > -1
            selector = {:$and => [{'visited' => false},
                                  {'depth'   => {:$lte => max_depth}}]}
          else
            selector = {'visited' => false}
          end
          @coll.find(selector).collect do | entry |
            entry['url']
          end
        end

        # Clear URL queue
        # @return [ Fixnum ] number of urls removed
        def clear(*opts)
          count = @coll.count
          @coll.remove
          count
        end

        # Get URL depth of given url
        # @param [ String ] url
        # return [ Fixnum ] URL depth
        def get_url_depth(url)
          @coll.find_one({'url' => url}, {:fields => ['depth']})['depth']
        end
      end
    end
  end
end
