---
layout: page
title: NewsCrawler
tagline: A flexible, modular web crawler
---
{% include JB/setup %}

# Getting started #

To crawl a site (e.g. www.example.com) with default configuration
and modules

    news_crawler www.example.com

You can resume crawling by invoke without any arguments.

    news_crawler

-----------------------------------------------

# Configuration #

NewsCrawler can be configured via YAML file, configuration for each
module is put on seperated file.

## Application configuration ##

Application's configuration can be loaded using `-c FILE` or `--app-conf FILE`
option.

**Default configuration**

    db:                        # database section
        :engine: :mongo        # database engine use (In the present, only MongoDB is support)

    :mongodb:                  # configuration for mongodb engine
        :host: localhost
        :port: !str 27017
        :db_name: news-crawler

    :suffix:                   # suffix for each collection in database
        :raw_data: raw_data
        :url_queue: url_queue

    prefix: ''                 # prefix (e.g. for each site is crawled)

## Included module configuration ##

### Same domain selector ###
Same domain selector's configuration can be loaded using `-s FILE` or
`--sds-conf FILE`

**Default configuration**

    :exclude:

List entry has following format

    domain:                    # e.g. example.com
        - [exclude_domain_part or /regular_expression/]
        - ...

Where:

* *exclude_domain_part* excludes URLs having the part seperated by `/` as
  specify. (e.g. `f1` exclude `example.com/f1`, `example.com/f1/f2`,...)
* */regular_expression/* excludes URLs matching the
  regex. (e.g. `/.*relax.*/` exclude all URLs has `relax` in
  this)

# What's next? #
* To add new storage engine to crawler, see [storage]({{BASE_PATH}}/pages/dev_storage_engine.html)
* To add new processing module to crawler, see [processing module development]({{BASE_PATH}}/pages/dev_processing_module.html)
