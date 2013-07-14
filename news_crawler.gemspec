require 'rake'

Gem::Specification.new do | s |
  s.name = 'news_crawler'
  s.version = '0.0.0'

  s.summary = 'News crawler'
  s.description = 'A flexible, modular web crawler'

  s.required_ruby_version = '>= 1.9.3'

  s.license = 'GPLv3'

  s.author = 'Hà Quang Dương'
  s.email = 'contact@haqduong.net'

  s.files = FileList['lib/**/*.rb'].to_a
  s.files << FileList['lib/**/*.yml'].to_a
  s.files << 'bin/news_crawler'

  s.executables = ['news_crawler']

  s.add_dependency 'typhoeus', '~> 0.6'
  s.add_dependency 'nokogiri', '~> 1.5'
  s.add_dependency 'celluloid', '~> 0.14'
  s.add_dependency 'simpleconfig', '~> 2.0'
  s.add_development_dependency 'simplecov', '~> 0.7'
end
