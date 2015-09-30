#!/usr/bin/env ruby
require 'fileutils'
require 'pathname'

dir1 = Pathname.new("/home/zeyad/Desktop/target_dir/test_dir/dir1/")

dir2 = Pathname.new("/home/zeyad/Desktop/target_dir/test_dir/dir2/")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# dir.mkpath # would create the path
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
dir1.mkpath 
dir2.mkpath


puts "The source DIR is : #{dir1}"
puts "The destination DIR is : #{dir2}"

#Dir.foreach(dir1) {|x| puts "Got #{x}" }
#Dir.foreach(dir2) {|x| puts "Got #{x}" }

Dir.foreach(dir1) 