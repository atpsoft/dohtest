module DohTest
extend self

def require_test_file(path, callbacks)
  callbacks.each do |callback|
    callback.call(path)
  end
  require(path)
end

def load_test_files(paths)
  callbacks = @config[:pre_require_callback]
  paths.each do |path|
    require_test_file(path, callbacks)
  end
end

end
