module DohTest
extend self

def require_test_file(path, callbacks)
  callbacks.each do |callback|
    callback.call(path)
  end
  require(path)
end

def require_paths(glob, paths)
  retval = false
  expanded_paths = paths.map {|path| File.expand_path(path) }
  callbacks = @config[:pre_require_callback]
  expanded_paths.each do |path|
    if File.directory?(path)
      Dir.glob(File.join(path, '**', glob)).each do |filename|
        retval = true
        DohTest.require_test_file(filename, callbacks)
      end
    else
      retval = true
      DohTest.require_test_file(path, callbacks)
    end
  end
  return retval
end

end
