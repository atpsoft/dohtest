module DohTest
extend self

def require_paths(glob, paths)
  retval = false
  paths.collect {|elem| File.expand_path(elem) }.each do |onepath|
    if File.directory?(onepath)
      Dir.glob(File.join(onepath, '**', glob)).each do |filename|
        retval = true
        require(filename)
      end
    else
      require(File.expand_path(onepath))
    end
  end
  retval
end

end
