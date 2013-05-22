module DohTest

def self.require_paths(glob, paths)
  paths.collect {|elem| File.expand_path(elem) }.each do |onepath|
    if File.directory?(onepath)
      Dir.glob(File.join(onepath, '**', glob)).each {|filename| require(filename)}
    else
      require(File.expand_path(onepath))
    end
  end
end

end
