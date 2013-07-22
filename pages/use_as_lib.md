---
layout: page
title: Using NewsCrawler as a library
categories: [using]
description: ""
---

You can use NewsCrawler as a library.

## Basic step ##
1. Require basic module

    require 'news_crawler'

    require 'news_crawler/config'

1. Load application (and modules) configuration (or you can setup
   SimpleConfig directly)

    NewsCrawler::CrawlerConfig.load_application_config(&lt;yaml_file&gt;)

1. Set engine for URLQueue and RawData

    NewsCrawler::Storage::RawData.set_engine(&lt;engine_name&gt;)
    NewsCrawler::Storage::URLQueue.set_engine(&lt;engine_name&gt;)

1. Start downloader and processing module

    dwl = NewsCrawler::Downloader.new(false)
    dwl.async.run

    # start modules

1. To stop downloader and processing module

    dwl.graceful_terminate    # Wait for all downloading threads are
    stopped

    dwl.terminate             # Celluloid actor terminate

-------------------------------

## Tips ##

You can reset database by call `URLQueue.clear` and/or
`RawData.clear`, when clear RawData you should reset downloading
status of URLQueue (`URLQueue.mark_all_unvisited`).
