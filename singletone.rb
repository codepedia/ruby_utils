#!/usr/bin/env ruby
require 'pathname'
require 'singleton'

class A
  define_singleton_method :loudly do |message|
    puts message.upcase
  end

indir = Pathname.new("/home/zeyad/Desktop/target_dir/srcdir")

# rm a dir and recreate it.
define_singleton_method :rm_and_mkdir do |dir_param|
      raise "don't do this" if $dir_name == ""
      run "rm -rf #{dir_param} && mkdir -p #{dir_param}"
    end
$indir = Pathname.new("/home/zeyad/Desktop/target_dir/srcdir")


end







A.loudly "my message"
A.rm_and_mkdir $indir
