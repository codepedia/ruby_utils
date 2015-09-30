#encoding : utf-8
#puts "#{Dir.pwd}目录中的内容："
#Dir.foreach(Dir.pwd) do |item|
#  puts item.to_s + "--" + item.split(".").count.to_s
#end

#puts Dir.glob('*')

class TestPath


# method to list all files in a goven directory @#TODO, create a method that will accomdate indir needs	
  def tpath(txtpath)
    Dir.foreach(txtpath) do |item|
      puts txtpath + "/" + item.to_s
      if item.split(".").count == 1 then
        tpath(txtpath + "/" + item.to_s )
      end
    end
  end

  

def subdirs
    subdirs = Array.new
    self.each do |x|
      puts "Evaluating file: #{x}"
      if File.directory?(x)
        puts "This file (#{x}) was considered a directory by File.directory?"
        subdirs.push(x)
        #yield(x) if block_given?
      end
    end
    return subdirs
  end


end

mydar = "/home/zeyad/Desktop/target_dir/dstdir"
txtp = TestPath.new
txtp.tpath("/home/zeyad/Desktop/target_dir/dstdir")