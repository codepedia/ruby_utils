#!/usr/bin/env ruby

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# just require and use it.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
require 'fileutils'
require 'chronic'
require 'pathname'
require 'better_errors'




indir = Pathname.new("/home/zeyad/Desktop/target_dir/srcdir/")
# => "/foo/bar"

outdir = Pathname.new("/home/zeyad/Desktop/target_dir/dstdir")
# => "/foo/bar"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# dir.mkpath # would create the path
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
indir.mkpath 
outdir.mkpath



Dir.foreach(indir) {|x| puts "Got #{x}" }

FileUtils.cp_r(indir, outdir)


Dir.chdir(indir)

puts "Hey man I am the =>> DIR :  #{Dir.pwd}"

Dir.chdir(outdir) do
puts  "Hey man  for =>> DIR :  #{Dir.pwd}"

end



#puts I am the file File.split(indir)
#FileUtils.compare_file(indir, outdir)  




puts "The source DIR is : #{indir}."
puts "The destination DIR is : #{outdir}."


#FileUtils.mv('/tmp/your_file', '/opt/new/location/your_file')








#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Different ways of  creating a directory. 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#FileUtils::mkdir_p '/home/zeyad/Desktop/target_dir/srcdir'
#
#path = "/tmp/a/b/c"
#FileUtils.mkdir_p(path) unless File.exists?(path)
#
#mkdir_p(list, options)
