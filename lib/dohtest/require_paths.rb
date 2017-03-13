module DohTest
extend self

def require_paths(glob, paths)
  retval = false
  expanded_paths = paths.map {|path| File.expand_path(path) }
  expanded_paths.each do |path|
    if File.directory?(path)
      Dir.glob(File.join(path, '**', glob)).each do |filename|
        retval = true
        require(filename)
      end
    else
      require(path)
    end
  end
  return retval
end

end
