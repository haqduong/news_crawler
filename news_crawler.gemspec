require 'rake'

Gem::Specification.new do | s |
  s.name    = 'news_crawler'
  s.version = '0.0.3'

  s.summary     = 'News crawler'
  s.description = 'A flexible, modular web crawler'
  s.homepage    = 'http://haqduong.github.io/news_crawler/'

  s.required_ruby_version = '>= 2.0.0'

  s.license = 'GPLv3'

  s.author  = 'Hà Quang Dương'
  s.email   = 'contact@haqduong.net'

  s.files = FileList['lib/**/*.rb'].to_a
  s.files << FileList['lib/**/*.yml'].to_a
  s.files << 'bin/news_crawler'

  s.executables = ['news_crawler']

  s.add_dependency 'mongo',        '>= 1.9'
  s.add_dependency 'typhoeus',     '~> 0.6'
  s.add_dependency 'nokogiri',     '~> 1.5'
  s.add_dependency 'celluloid',    '~> 0.14'
  s.add_dependency 'simpleconfig', '~> 2.0'
  s.add_dependency 'robots',       '~> 0.10'

  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'minitest',  '~> 5.0'
  s.add_development_dependency 'mocha',     '~> 0.14'
  s.add_development_dependency 'coveralls'
end
