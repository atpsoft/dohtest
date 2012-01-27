require 'rake'

Gem::Specification.new do |s|
  s.name = 'dohtest'
  s.version = '0.1.1'
  s.summary = 'Minimalist unit test framework.'
  s.description = %q{
  This is a fairly straight forward replacement for minitest, though some changes to test code are required.
  Code is intended to be easy to understand and extend. Includes command line runner to make execution convenient.
  Designed for speed, including running tests concurrently (though as of this version that's not implemented).
  }
  s.require_path = 'lib'
  s.required_ruby_version = '>= 1.9.2'
	s.add_runtime_dependency 'dohutil', '>= 0.1.0'
  s.authors = ['Makani Mason', 'Kem Mason']
  s.bindir = 'bin'
  s.homepage = 'https://github.com/atpsoft/dohtest'
  s.license = 'MIT'
  s.email = ['devinfo@atpsoft.com']
  s.extra_rdoc_files = ['MIT-LICENSE']
  s.test_files = FileList["{test}/**/*.rb"].to_a
  s.executables = FileList["{bin}/**/*"].to_a.collect { |elem| elem.slice(4..-1) }
  s.files = FileList["{bin,lib,test}/**/*"].to_a
end
