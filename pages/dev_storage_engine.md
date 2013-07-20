---
layout: page
title: Storage engine development
categories: [development]
description: ""
---
{% include JB/setup %}

There are 2 main storage modules in NewsCrawler:

* URLQueue: Store URLs list and processing information (unprocessed,
  processing, processed).

* RawData: Store HTML page.

# Storage engine development

1. Inherited corresponding class
   (`NewsCrawler::Storage::RawData::RawDataEngine` and
   ` NewsCrawler::Storage::URLQueue::URLQueueEngine`).

1. Give it a name by provide `NAME` constant.

1. Implement all methods with purpose described in API.

1. Use `URLQueue.set_engine` and `RawData.set_engine` to use your
   engine (using `NAME` you specified above)
