module DohTest
extend self

def find_files(glob, paths)
  retval = []
  expanded_paths = paths.map {|path| File.expand_path(path) }
  expanded_paths.each do |path|
    if File.directory?(path)
      retval.concat(Dir.glob(File.join(path, '**', glob)).to_a)
    else
      retval << path
    end
  end
  return retval
end

end
