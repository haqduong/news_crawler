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
  # Contains various method for processing url
  module URLHelper
    # produce true if 2 urls belong to same domain, or url is start with '/'
    # @param  [ String  ] url1 Url 1
    # @param  [ String  ] url2 Url 2
    # @return [ Boolean ] true if both url belong to same domain
    def same_domain?(url1, url2)
      if (url1[0] == '/') || (url2[0] == '/')
        return true
      end
      p1 = get_url_path(url1)
      p2 = get_url_path(url2)
      d1 = p1[:domain].split('.').reverse
      d2 = p2[:domain].split('.').reverse
      d1.zip(d2).inject(true) do | mem, obj |
        mem = mem && ((obj[0] == obj[1]) || (obj[0].nil? || obj[1].nil?))
      end
    end

    # split URL into 3 parts: scheme, domain, path
    # @param [ String ] url
    # return [ Hash   ] contains parts
    def get_url_path(url)
      pattern = /((?<scheme>(http|https)):\/\/)?(?<domain>[^\/]+)?(?<path>\/.*)?/
      md = pattern.match(url)
      { :scheme => md[:scheme],
        :domain => md[:domain],
        :path => md[:path]}
    end
  end
end
