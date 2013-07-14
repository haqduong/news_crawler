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

require 'celluloid'
require 'typhoeus'
require 'simpleconfig'

require 'news_crawler/config'
require 'news_crawler/storage/raw_data'
require 'news_crawler/utils/robots_patch'

module NewsCrawler
  # This class implement an parallel downloader based on Typhoes
  # with given queue
  class Downloader
    include Celluloid

    CONCURRENT_DOWNLOAD = 4

    # Construct downloader with an URLQueue
    # @param [ Boolean ] start_on_create whether start selector immediately
    # @param [ NewsCrawler::URLQueue ] queue url queue
    def initialize(start_on_create = true, queue = NewsCrawler::Storage::URLQueue, **opts)
      @queue = queue
      @urls = queue.find_unvisited
      @concurrent_download = opts[:concurrent] || CONCURRENT_DOWNLOAD
      @wait_time = 1
      @status = :running
      @stoping = false
      wait_for_url if start_on_create
    end

    # Start downloader with current queue
    # URL successed fetch is marked and result's stored in DB
    def run
      @status = :running
      hydra = Typhoeus::Hydra.new(max_concurrency: @concurrent_download)
      # TODO Log here
      @urls = @urls.keep_if do | url |
        Robots.instance.allowed? url
      end
      requests = @urls.map do | url |
        re = Typhoeus::Request.new(url, followlocation: true)
        re.on_complete do | response |
          if response.success?
            Storage::RawData.add(url, response.response_body)
            @queue.mark_visited url
          else
            raise "Fetch error"
          end
        end
        hydra.queue re
        re
      end
      hydra.run
      @urls = []
      wait_for_url
    end

    # Graceful terminate this downloader
    def graceful_terminate
      @stoping = true
      while @status == :running
        sleep(1)
      end
    end

    private
    # Waiting for new urls're added to queue, using backoff algorithms
    def wait_for_url
      @status = :waiting
      if @stoping # check for stop flag
        return
      end
      sleep @wait_time
      get_new_url
      if @urls.size == 0
        if @wait_time < 30
          @wait_time = @wait_time * 2
        end
        wait_for_url
      else
        @wait_time = 1
        run
      end
    end

    def get_new_url
      @urls = @queue.find_unvisited
    end
  end
end
