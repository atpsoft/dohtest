require 'doh/root'

module DohTest

def self.config
  @config ||= {}
end

def self.load_configuration_files(start_path)
  start_directory = File.dirname(start_path)
  root_directory = Doh::find_root(start_directory)

  local_filename = Doh::findup(start_directory, 'configure_dohtest.rb')
  if local_filename && File.exist?(local_filename)
    require(local_filename)
    return
  end

  if root_directory
    root_filename = File.join(root_directory, 'config', 'dohtest.rb')
    require(root_filename) if File.exist?(root_filename)
  end
end

def self.add_default_config_values
  DohTest::config[:glob] ||= '*.dt.rb'
  DohTest::config[:seed] ||= (Time.new.to_f * 1000).to_i
end

def self.configure(start_path)
  load_configuration_files(start_path)
  add_default_config_values
end

end
