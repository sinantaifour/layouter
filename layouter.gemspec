require_relative 'lib/layouter/version'

DIR = File.expand_path(File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = 'layouter'
  s.version     = Layouter::VERSION
  s.date        = '2011-12-30'
  s.authors     = ['Sinan Taifour']
  s.email       = 'sinan@taifour.com'
  s.summary     = "A layout engine for terminals."
  s.description = "A layout engine for terminals."
  s.files       = Dir[DIR + '/lib/**/*.rb']
  s.license     = 'MIT'

  s.add_development_dependency 'rake', '~> 12.0'
end
