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

require 'nokogiri'
require 'uri'

require 'news_crawler/url_helper'
require 'news_crawler/storage/url_queue'
require 'news_crawler/storage/raw_data'
require 'news_crawler/crawler_module'

module NewsCrawler
  module Processing
    # Analyse website structure to extract content
    # Database should only contains raw data from one website.
    class StructureAnalysis
      include CrawlerModule
      include URLHelper

      def initialize
        @url_stats = {}
        while (url = next_unprocessed)
          analyse(url)
        end
      end

      # Get and analyse url for information
      def analyse(url)
#        puts "processing #{url}"
        html_doc = RawData.find_by_url(url)
        doc = Nokogiri.HTML(html_doc)
        inner_url = doc.xpath('//a').collect { | a_el |
          temp_url = (a_el.attribute 'href').to_s
          if (!temp_url.nil?) && (temp_url[0] == '/')
            temp_url = URI.join(url, temp_url).to_s
          end
          temp_url
        }

        inner_url.delete_if { | url_0 |
          (url_0.nil?) || (url_0.size == 0) || (url_0 == '#') ||
          (url_0 == 'javascript:;')
        }

        inner_url.each do  | url |
          @url_stats[url] = (@url_stats[url] || 0) + 1
        end
        mark_processed(url)
      end

      # Check if it is really 'url'
      # @param [ String ] url
      # @return [ Boolean ]
      def is_url?(url)
        (url.size != 0) && (url != '#') && (url != 'javascript:;')
      end

      def get_result
        @url_stats
      end
    end
  end
end
