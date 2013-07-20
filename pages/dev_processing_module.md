---
layout: page
title: Processing module development
categories: [development]
description: ""
---
{% include JB/setup %}

Only 2 steps to integrate new module to NewsCrawler.

1. Include CrawlerModule
    class FooModule < NewsCrawler::CrawlerModule

1. Using provided methods to interact with database.

## Normal workflow ##

1. Call `next_unprocessed` (or `next_unprocessed(<max_depth>)`) to get
   next unprocessed url (with limited depth)

1. Call `RawData::find_by_url` to get coresponding page.

1. Process it.

1. Store it somewhere (*I'll provide storage soon*)
