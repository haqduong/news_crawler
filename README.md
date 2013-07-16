NewsCrawler
===========
NewsCrawler is a flexible, modular web crawler intended to provide
website analysis framework.

[![Build Status](https://travis-ci.org/haqduong/news_crawler.png?branch=master)](https://travis-ci.org/haqduong/news_crawler)
[![Coverage Status](https://coveralls.io/repos/haqduong/news_crawler/badge.png?branch=master)](https://coveralls.io/r/haqduong/news_crawler?branch=master)

Getting started
===============
CLI
---
    news_crawler -d <maximum depth> <url>
You can pass configuration file to customize database parameter and
modules' configuration.

Usage
=====
CLI
---
    Usage: news_crawler [options] url
        -c, --app-conf FILE              Application configuration file
        -s, --sds-conf FILE              Same domain selector configuration file
        -d, --max-depth DEPTH            Maximum depth of url to crawl

Requirements
============
* Ruby >= 1.9.3
* MongoDB

Caution
=======
This is a prelease version, so API can be changed significantly.

Copyright
=========
Copyright (C) 2013 Hà Quang Dương <contact@haqduong.net>

NewsCrawler is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

NewsCrawler is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with NewsCrawler.  If not, see <http://www.gnu.org/licenses/>.
