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
require 'news_crawler/storage/yaml_stor'
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
          #!!! log here
          #STDERR.puts "Processing #{url}"
          re = extract_content(url)
          @url_stats[url] = re
          save_yaml(re)
        end
      end

      def extract_content(url)
        html_doc = RawData.find_by_url(url)
        result = {}
        result[:type] == :article

        # Remove tag causing trouble to nokogiri
        html_doc = remove_tag(html_doc, 'script')
        html_doc = remove_tag(html_doc, 'iframe')
        html_doc = remove_tag(html_doc, 'style')

        doc = Nokogiri::HTML.parse(html_doc)
        longest = find_longest_node(doc)
        lowest_ancestor, path_to_longest = find_lowest_ancestor_has_id(longest)

        # Heuristic 1
        # Longest content is a element as id attribute
        if path_to_longest.length == 2
          return { :type => :list }
        end

        parent = path_to_longest[1..-1]
        parent = parent.reverse
        xpath_path = parent.join('/')
        xpath_path = '//' + xpath_path + '//text()'

        guest_type = classify_h2(longest, lowest_ancestor)
        result = { :type => guest_type }

        if (result[:type] == :article)
          title_ = lowest_ancestor.css('h1')
          if title_.count == 1
            result[:title] = title_.to_a[0].content
          end

          main_content = ''
          lowest_ancestor.xpath(xpath_path).each do | node |
            main_content += node.content
          end

          result[:content] = main_content
        end

        mark_processed(url)
        result
      end

      # Predict type of tree point by root is fragment of article or index page
      # @param [ Nokogiri::XML::Node ] root
      # @paran [ Nokogiri::XML::Node ] limit limit node to search backward
      # @return [ Symbol ] one of :article, :list
      def classify_h2(root, limit)
        current = root
        current = current.parent if current.text?

        depth = 0

        while true
          expect_hash = hash_node(current, 0)
          previous = current
          current = current.parent

          depth += 1
          lons = {}
          node_count = 0
          node_list = [previous]
          current.children.each do | child |
            hc = hash_node(child, depth - 1)
            if hc == expect_hash
              node_count += 1
              node_list << child
            end
          end

          if node_count > 1
            a_tag_len, non_a_tag_len = count_a_and_non_a_tag(current)
            if non_a_tag_len > a_tag_len
              return :article
            else
              return :list
            end
            break
          end

          if current == limit
            a_tag_len, non_a_tag_len = count_a_and_non_a_tag(current)
            if non_a_tag_len > a_tag_len
              return :article
            else
              return :list
            end
            break
          end
        end

        return :list
      end

      # Count a tag and non-a tag in tree pointed by node
      # @param [ Nokogiri::XML::Node ] node
      # @return [ [Fixnum, Fixnum] ] a tag and non-a tag
      def count_a_and_non_a_tag(node)
        a_tag_list = node.xpath './/a'
        a_tag_len = a_tag_list.count # number of a tag

        non_a_tag_list = node.xpath './/text()[not (ancestor::a)]'
        non_a_tag_len = non_a_tag_list.to_a.inject(0) do | memo, node |
          if node.content.gsub(/\s+/, '').length > 15
            memo + 1
          else
            memo
          end
        end
        [ a_tag_len, non_a_tag_len ]
      end

      # Find the lowest node's ancestor has id attribute
      # @param [ Nokogiri::XML::Node ] node
      # @return [ Nokogiri::XML::Node ]
      def find_lowest_ancestor_has_id(node)
        found_id = false

        closest_ancestor = node

        path_to_closest = []

        while (!found_id)
          if closest_ancestor.has_attribute?('id')
            path_to_closest << "#{closest_ancestor.node_name}[@id='#{closest_ancestor.attribute('id')}']"
            found_id = true
          else
            if closest_ancestor.has_attribute?('class')
              node_class = "@class = '#{closest_ancestor.attribute('class')}'"
            else
              node_class = 'not(@class)'
            end
            path_to_closest << "#{closest_ancestor.node_name}[#{node_class}]"
            closest_ancestor = closest_ancestor.parent
          end
        end

        return [ closest_ancestor, path_to_closest ]
      end

      # Find longest text node that doesn't have a in ancestors list
      # @param [ Nokogiri::XML::Node ] doc
      def find_longest_node(doc)
        xpath_query = '//*[@id]//text()[not (ancestor::a)]'

        a_l = doc.xpath xpath_query

        longest = nil
        longest_len = 0

        a_l.each do | en |
          node_content_wo_space = en.content.gsub(/\s/, '') # trick here
          if node_content_wo_space.length > longest_len
            longest_len = node_content_wo_space.length
            longest = en
          end
        end

        return longest
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

      # Calculate hash of a node by its and children info
      # @param [ Nokogiri::XML::Node ] node
      # @param [ Fixnum ] limit limit depth of children (-1 for unlimited)
      # @return [ String ] Hash of node in base 64 encode
      def hash_node(node, limit = -1)
        node_sign = node.node_name
        node_sign += "##{node['id']}" unless node['id'].nil?
        node_sign += ".#{node['class']}" unless node['class'].nil?

        hash_sum = node_sign

        if limit != 0
          child_hash = Set.new
          node.children.each do | child_node |
            child_hash.add(hash_node(child_node, limit - 1))
          end

          child_hash.each do | ch |
            hash_sum += ch
          end
        else

        end

        Digest::SHA2.new.base64digest(hash_sum)
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
