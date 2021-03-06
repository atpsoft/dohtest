require 'dohroot'
require 'dohtest/find_files'

module DohTest
extend self

def config
  @config ||= {:post_all_callback => [], :pre_group_callback => [], :post_group_callback => [], :pre_test_callback => [],
    :pre_each_callback => [], :post_each_callback => [], :pre_require_callback => []}
end

def find_root(start_directory, max_tries = 20)
  curr_directory = start_directory
  max_tries.times do
    return nil if curr_directory == '/'
    if (File.exist?(File.join(curr_directory, 'dohroot')) ||
        File.directory?(File.join(curr_directory, 'test')) ||
        File.exist?(File.join(curr_directory, 'dohtest.rb')))
      return curr_directory
    end
    curr_directory = File.expand_path(File.join(curr_directory, '..'))
  end
  nil
end

def load_configuration_file(start_path)
  start_path = File.expand_path(start_path || '.')
  if File.directory?(start_path)
    start_directory = start_path
  else
    start_directory = File.dirname(start_path)
  end

  root_directory = find_root(start_directory)
  if !root_directory
    raise "unable to determine root directory to run tests from"
  end
  DohTest.config[:root] = root_directory

  Doh.find_root_from_path(root_directory)
  libdir = File.join(root_directory, 'lib')
  if File.directory?(libdir) && !$LOAD_PATH.include?(libdir)
    $LOAD_PATH << libdir
  end

  cfgfile = File.join(root_directory, 'dohtest.rb')
  if File.exist?(cfgfile)
    require(cfgfile)
    return
  end

  cfgfile = File.join(root_directory, 'config', 'dohtest.rb')
  if File.exist?(cfgfile)
    require(cfgfile)
    return
  end

end

def add_default_config_values
  DohTest.config[:glob] ||= '*.dt.rb'
  DohTest.config[:seed] ||= (Time.new.to_f * 1000).to_i
end

def set_test_files
  paths = DohTest.config[:paths]
  if paths.empty?
    paths = ['.']
  end
  DohTest.config[:test_files] = DohTest.find_files(DohTest.config[:glob], paths)
end

def configure(start_path)
  add_default_config_values
  set_test_files
  load_configuration_file(start_path)
end

end
