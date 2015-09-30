#!/usr/bin/env ruby
require 'fileutils'

def run

my_dir="/home/zeyad/rubyterminals/file_tansfer/new_dir"
create_a_directory(my_dir)

end


def create_a_directory(dir_name)
#    nice_directory_text = special_file_directory_attribute.to_s.gsub("_"," ")
    
    if dir_name
      # dir_name was specified, ensure it is created and writable.
      unless File.exist?(dir_name)
        begin
          FileUtils.mkdir_p(dir_name)
           puts "just made the following dir #{dir_name}"
        rescue Errno::EACCES => e
          abort "Failed to create #{dir_name}: #{e.message}"
        end
      end
end
end

run
