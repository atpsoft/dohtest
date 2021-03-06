require 'rake'

Gem::Specification.new do |s|
  s.name = 'dohtest'
  s.version = '0.1.54'
  s.summary = 'minimalist unit test framework'
  s.description = 'Minimalist unit test framework, easy to understand and extend.'
  s.require_path = 'lib'
  s.required_ruby_version = '>= 2.6.0'
  s.add_runtime_dependency 'dohroot', '~> 0.1'
  s.add_runtime_dependency 'term-ansicolor', '~> 1'
  s.authors = ['ATPSoft']
  s.bindir = 'bin'
  s.homepage = 'https://github.com/atpsoft/dohtest'
  s.license = 'MIT'
  s.email = ['devinfo@atpsoft.com']
  s.extra_rdoc_files = ['MIT-LICENSE']
  s.test_files = FileList["{test}/**/*.rb"].to_a
  s.executables = FileList["{bin}/**/*"].to_a.collect { |elem| elem.slice(4..-1) }
  s.files = FileList["{bin,lib,test}/**/*"].to_a
end
