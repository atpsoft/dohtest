require 'doh/root'

module DohTest

def self.configure(start_path)
  start_directory = File.dirname(start_path)

  root_directory = Doh::find_root(start_directory)
  if root_directory
    root_filename = File.join(root_directory, 'config', 'dohtest.rb')
    require(root_filename) if File.exist?(root_filename)
  end

  local_filename = Doh::findup(start_directory, 'configure_dohtest.rb')
  require(local_filename) if local_filename && File.exist?(local_filename)
end

end
