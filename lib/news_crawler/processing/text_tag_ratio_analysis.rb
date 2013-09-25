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
require 'news_crawler/nc_logger'

module NewsCrawler
  module Processing
    # Analyse website structure to extract content
    # Database should only contains raw data from one website.
    class TextTagRatioAnalysis
      include CrawlerModule
      include URLHelper

      def initialize
        @url_stats = {}
        while (url = next_unprocessed)
          NCLogger.get_logger.info "[NC::P::SA] Processing #{url}"
          re = extract_content(url)
          @url_stats[url] = re
#          @url_stats[url] = re
#          save_yaml(url, re)
        end
      end

      def extract_content(url)
        html_doc = RawData.find_by_url(url)
        result = {}
        result[:type] = :list

        # Remove tag causing trouble to nokogiri
        html_doc = remove_tag(html_doc, 'script')
        html_doc = remove_tag(html_doc, 'iframe')
        html_doc = remove_tag(html_doc, 'style')

        doc = Nokogiri::HTML.parse(html_doc)

        # Heuristic 1: Find h1 tag
        h1_elem = doc.xpath("//h1")
        h1_elem = h1_elem.to_a.delete_if do | node |
          text_length, no_of_tags = text_tag_count(node)
          text_length == 0
        end
        if h1_elem.size > 1
          return result
        end
        h1_elem.each do | node |
          result, best_node = get_content(node)
          a_count = best_node.xpath('.//a').to_a.inject(0) do | memo, node |
            memo + strip_multiple_whitespace(node.text).length
          end
          total_count = strip_multiple_whitespace(best_node.inner_text).length
          ratio = a_count * 1.0 / total_count
          if ratio >= 0.2
            result = { type: :list }
          end
        end
        result
      end

      # Eliminate continuous whitespace
      def strip_multiple_whitespace(text)
        text.gsub(/\s+/, ' ')
      end

      # Guess content of page has 'node' h1
      def get_content(node)
        result = {}
        cur = node
        best_diff = 0.0
        best_node = cur
        prev_tl, prev_not = text_tag_count(cur)
        while (cur.type != Nokogiri::XML::Node::HTML_DOCUMENT_NODE)
          text_length, no_of_tags = text_tag_count(cur) # [Text  / no of tags ]
          if (no_of_tags - prev_not != 0)
            diff = (text_length - prev_tl) * 1.0 / (no_of_tags - prev_not)
            if diff > best_diff
              best_diff = diff
              best_node = cur
              #puts "Best node: #{cur.name} #{cur['id'].to_s} #{cur['class'].to_s}"
            end
          end
          prev_tl, prev_not = text_length, no_of_tags
          cur = cur.parent
        end

        result[:type] = :article
        result[:title] = get_non_a_text(node)
        node.content = ''
        result[:content] = get_non_a_text(best_node).strip
        [result, best_node]
      end

      def get_non_a_text(elem)
        elem.children.to_a.inject('') do | memo, child |
          if child.text?
            text = child.text
            text.gsub!(/^\s+/, ' ')
            text.gsub!(/\s{2,}/, ' ')
            memo + child.text.gsub("\n", ' ')
          elsif child.name == 'a'
            memo
          elsif block_tag?(child.name)
            text = get_non_a_text(child).strip
            text = memo + text
            text.gsub!(/^\s+/, '')
            text.gsub!(/\s+$/, '')
            text + "\n"
          else                                   # inline tags
            memo + get_non_a_text(child)
          end
        end
      end

      def block_tag?(tag_name)
        ['h1', 'h2', 'h3', 'h4', 'h5', 'h6',
         'p', 'ul', 'ol', 'table', 'div'].include? tag_name
      end

      # Caculate words to tags ratio (without words in a tag)
      def text_tag_count(elem)
        text_nodes = elem.xpath './/text()[not (ancestor::a)]'
        inner_texts = text_nodes.map do | node |
          node.content.strip
        end
        inner_texts.delete_if { | txt | txt.length == 0 }
        text_length = inner_texts.inject(0) { | memo, txt | memo + txt.length }

        no_of_tags = no_of_tags(elem)

#        puts "Text length: " + text_length.to_s
#        puts "No of tags: " + no_of_tags.to_s

        [text_length, no_of_tags]
      end

      # Count number of tags in elem
      def no_of_tags(elem)
        elem.children.inject(1) do | memo, node |
          if node.text?
            memo
          else
            memo + 1 + no_of_tags(node)
          end
        end
      end

      # Remove unwanted HTML tag
      # @param [ String ] html_doc HTML document
      # @param [ String ] tag tag to be removed
      def remove_tag(html_doc, tag)
        pattern = Regexp.new("<#{tag}.*?>.*?</#{tag}>", Regexp::MULTILINE)
        html_doc.gsub(pattern, '')
      end

      # Return String represents node's name, node's id and node's class
      # @param [ Nokogiri::XML::Node ] node
      # @return [ String ]
      def node_info(node)
        node_pp = node.node_name
        node_pp += '#' + node.attribute('id') if node.has_attribute?('id')
        node_pp += '.' + node.attribute('class') if node.has_attribute?('class')
        node_pp
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
