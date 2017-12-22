module DohTest
extend self

def require_test_file(path)
  require(path)
end

def require_paths(glob, paths)
  retval = false
  expanded_paths = paths.map {|path| File.expand_path(path) }
  expanded_paths.each do |path|
    if File.directory?(path)
      Dir.glob(File.join(path, '**', glob)).each do |filename|
        retval = true
        DohTest.require_test_file(filename)
      end
    else
      retval = true
      DohTest.require_test_file(path)
    end
  end
  return retval
end

end
