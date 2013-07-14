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

require 'news_crawler/storage/url_queue'
require 'thread'

module NewsCrawler
  # Include this to get basic module methods
  module CrawlerModule
    # Mark current url process state of current module is processed
    # @param [ String ] url
    def mark_processed(url)
      URLQueue.mark(self.class.name, url, URLQueue::PROCESSED)
    end

    # Mark current url process state of current module is unprocessed
    # @param [ String ] url
    def mark_unprocessed(url)
      URLQueue.mark(self.class.name, url, URLQueue::UNPROCESSED)
    end

    # Find all visited unprocessed url
    # @param  [ Fixnum ] max_depth max url depth return (inclusive)
    # @return [ Array  ]  URL list
    def find_unprocessed(max_depth = -1)
      URLQueue.find_all(self.class.name, URLQueue::UNPROCESSED, max_depth)
    end

    # Find one visited url with given current module process state
    # @param  [ String ] state one of unprocessed, processing, processed
    # @param  [ Fixnum ] max_depth max url depth return (inclusive)
    # @return [ Array  ]  URL list
    def find_all(state, max_depth = -1)
      URLQueue.find_all(self.class.name, state, max_depth)
    end

    # Find all visited urls with current module's state
    # @param  [ String      ] state
    # @param  [ Fixnum      ] max_depth max url depth return (inclusive)
    # @return [ String, nil ] URL or nil if url doesn't exists
    def find_one(state, max_depth = -1)
      URLQueue.find_one(self.class.name, state, max_depth)
    end

    # Get next unprocessed a url and mark it as processing in atomic
    # @param  [ Fixnum ] max_depth max url depth return (inclusive)
    # @return [ String, nil ] URL or nil if url doesn't exists
    def next_unprocessed(max_depth = -1)
      URLQueue.next_unprocessed(self.class.name, max_depth)
    end
  end
end
