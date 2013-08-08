SimpleCov.start do
  add_filter '/test/'
  add_filter '/lib/news_crawler/storage/url_queue/url_queue_engine.rb'
  add_filter '/lib/news_crawler/storage/raw_data/raw_data_engine.rb'
  add_filter '/lib/news_crawler/storage/yaml_stor/yaml_stor_engine.rb'
  add_filter '/lib/news_crawler/crawler_module.rb'
  add_group 'Storage', 'storage'
  command_name 'minitest'
end
