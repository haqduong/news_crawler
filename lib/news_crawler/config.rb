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
require 'yaml'

module NewsCrawler
  class CrawlerConfig
    DEFAULT_CONFIG     = File.join(File.dirname(__FILE__),
                                   './default_config.yml')
    DEFAULT_SDS_CONFIG = File.join(File.dirname(__FILE__),
                                   './default_sds.yml')

    def self.load_application_config(file = CrawlerConfig::DEFAULT_CONFIG)
      if ((file != DEFAULT_CONFIG) || (@app_loaded != true))
        @app_loaded = true
        merge_config(:application, file)
      end
    end

    def self.load_samedomainselector_config(file = CrawlerConfig::DEFAULT_SDS_CONFIG)
      if ((file != DEFAULT_SDS_CONFIG) || (@sds_loaded != true))
        @sds_loaded = true
        merge_config(:same_domain_selector, file)
      end
    end

    def self.merge_config(mod, file)
      conf = YAML.load_file(file)
      conf.each do | key, val |
        if val.is_a? Hash
          val.each do | k1, v1 |
            SimpleConfig.for mod do
              group key do
                set k1, v1
              end
            end
          end
        else
          SimpleConfig.for mod do
            set key, val
          end
        end
      end
    end
  end
end

NewsCrawler::CrawlerConfig.load_application_config
NewsCrawler::CrawlerConfig.load_samedomainselector_config
