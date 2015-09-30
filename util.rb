require "cgi"
require "digest/md5"
require "etc"
require "fileutils"
require "yaml"


  # Helper module for executing commands and printing stuff
  # out.
  #
  # The general idea is to only print commands that are actually
  # interesting. For example, mkdir_if_necessary won't print anything
  # if the directory already exists. That way we can scan teleport
  # output and see what changes were made without getting lost in
  # repetitive commands that had no actual effect.

    class Myutil

    RESET   = "\e[0m"
    RED     = "\e[1;37;41m"
    GREEN   = "\e[1;37;42m"
    YELLOW  = "\e[1;37;43m"
    BLUE    = "\e[1;37;44m"
    MAGENTA = "\e[1;37;45m"
    CYAN    = "\e[1;37;46m"


    def initialize(util_access)
    @util_access  = util_access
  end

    #
    # running commands
    #

    # Make all commands echo before running.
    def run_verbose!
      @run_verbose = true
    end

    # Run a command, raise an error upon failure. Output goes to
    # $stdout/$stderr.
    def run(command, args = nil)
      line = nil
      if args
        args = args.map(&:to_s)
        line = "#{command} #{args.join(" ")}"
        vputs line
        system(command, *args)
      else
        line = command
        vputs line
        system(command)
      end
      if $? != 0
        if $?.termsig == Signal.list["INT"]
          raise "#{line} interrupted"
        end
        raise RunError, "#{line} failed : #{$?.to_i / 256}"
      end
    end

    # Run a command, raise an error upon failure. The output is
    # captured as a string and returned.
    def run_capture(command, *args)
      if !args.empty?
        args = args.flatten.map { |i| shell_escape(i) }.join(" ")
        command = "#{command} #{args}"
      end
      result = `#{command}`
      if $? != 0
        if $?.termsig == Signal.list["INT"]
          raise "#{command} interrupted"
        end
        raise RunError, "#{command} failed : #{$?.to_i / 256} #{result.inspect}"
      end
      result
    end

    # Run a command and split the result into lines, raise an error
    # upon failure. The output is captured as an array of strings and
    # returned.
    def run_capture_lines(command, *args)
      run_capture(command, args).split("\n")
    end

    # Run a command but don't send any output to $stdout/$stderr.
    def run_quietly(command, *args)
      if !args.empty?
        args = args.flatten.map { |i| shell_escape(i) }.join(" ")
        command = "#{command} #{args}"
      end
      run("#{command} > /dev/null 2> /dev/null")
    end

    # Run one or several commands, separate by newlines.
    def shell(commands)
      commands.split("\n").each { |i| run(i) }
    end

    # Run a command, return true if it succeeds.
    def succeeds?(command)
      system("#{command} > /dev/null 2> /dev/null")
      $? == 0
    end

    # Run a command, return true if it fails.
    def fails?(command)
      !succeeds?(command)
    end

    # Escape some text for the shell and enclose it in single quotes
    # if necessary.
    def shell_escape(s)
      s = s.to_s
      if s !~ /^[0-9A-Za-z+,.\/:=@_-]+$/
        s = s.gsub("'") { "'\\''" }
        s = "'#{s}'"
      end
      s
    end

    # Like mkdir -p. Optionally, set the owner and mode.
    def mkdir(dir, owner = nil, mode = nil)
      FileUtils.mkdir_p(dir, :verbose => verbose?)
      chmod(dir, mode) if mode
      chown(dir, owner) if owner
    end

    # mkdir only if the directory doesn't already exist. Optionally,
    # set the owner and mode.
    def mkdir_if_necessary(dir, owner = nil, mode = nil)
      mkdir(dir, owner, mode) if !(File.exists?(dir) || File.symlink?(dir))
    end

    # rm a dir and recreate it.
    def rm_and_mkdir(dir)
      raise "don't do this" if dir == ""
      run "rm -rf #{dir} && mkdir -p #{dir}"
    end

    # Are two files different?
    def different?(a, b)
      !FileUtils.compare_file(a, b)
    end

    # Copy perms from src file to dst.
    def copy_perms(src, dst)
      stat = File.stat(src)
      File.chmod(stat.mode, dst)
    end

    # Copy perms and timestamps from src file to dst.
    def copy_metadata(src, dst)
      stat = File.stat(src)
      File.chmod(stat.mode, dst)
      File.utime(stat.atime, stat.mtime, dst)
    end

    # Copy file or dir from src to dst. Optionally, set the mode and
    # owner of dst.
    def cp(src, dst, owner = nil, mode = nil)
      FileUtils.cp_r(src, dst, :preserve => true, :verbose => verbose?)
      if owner && !File.symlink?(dst)
        chown(dst, owner)
      end
      if mode
        chmod(dst, mode)
      end
    end

    # Copy file or dir from src to dst, but create the dst directory
    # first if necessary. Optionally, set the mode and owner of dst.
    def cp_with_mkdir(src, dst, owner = nil, mode = nil)
      mkdir_if_necessary(File.dirname(dst))
      cp(src, dst, owner, mode)
    end

    # Copy file or dir from src to dst, but ONLY if dst doesn't exist
    # or has different contents than src. Optionally, set the mode and
    # owner of dst.
    def cp_if_necessary(src, dst, owner = nil, mode = nil)
      if !File.exists?(dst) || different?(src, dst)
        cp(src, dst, owner, mode)
        true
      end
    end

    # Move src to dst. Because this uses FileUtils, it works even if
    # dst is on a different partition.
    def mv(src, dst)
      FileUtils.mv(src, dst, :verbose => verbose?)
    end

    # Move src to dst, but create the dst directory first if
    # necessary.
    def mv_with_mkdir(src, dst)
      mkdir_if_necessary(File.dirname(dst))
      mv(src, dst)
    end

    # Chown file to be owned by user.
    def chown(file, user)
      user = user.to_s
      # who is the current owner?
      @uids ||= {}
      @uids[user] ||= Etc.getpwnam(user).uid
      uid = @uids[user]
      if File.stat(file).uid != uid
        run "chown #{user}:#{user} '#{file}'"
      end
    end

    # Chmod file to a new mode.
    def chmod(file, mode)
      if File.stat(file).mode != mode
        begin
          FileUtils.chmod(mode, file, :verbose => verbose?)
        rescue NoMethodError
          # workaround https://bugs.ruby-lang.org/issues/8547
          FileUtils.chmod(mode, file)
        end
      end
    end

    # rm a file
    def rm(file)
      FileUtils.rm(file, :force => true, :verbose => verbose?)
    end

    # rm a file, but only if it exists.
    def rm_if_necessary(file)
      if File.exists?(file)
        rm(file)
        true
      end
    end

    # Create a symlink from src to dst.
    def ln(src, dst)
      FileUtils.ln_sf(src, dst, :verbose => verbose?)
    end

    # Create a symlink from src to dst, but only if it hasn't already
    # been created.
    def ln_if_necessary(src, dst)
      ln = false
      if !File.symlink?(dst)
        ln = true
      elsif File.readlink(dst) != src
        rm(dst)
        ln = true
      end
      if ln
        ln(src, dst)
        true
      end
    end

    # A nice printout in green.
    def banner(s, color = GREEN)
      s = "#{s} ".ljust(72, " ")
      $stderr.write "#{color}[#{Time.new.strftime('%H:%M:%S')}] #{s}#{RESET}\n"
      $stderr.flush
    end

    # Print a warning in yellow.
    def warning(msg)
      banner("Warning: #{msg}", YELLOW)
    end

    # Print a fatal error in red, then exit.
    def fatal(msg)
      banner(msg, RED)
      exit(1)
    end

    # Who owns this process?
    def whoami
      @whoami ||= Etc.getpwuid(Process.uid).name
    end

    # Install gem if necessary.
    def gem_if_necessary(gem)
      grep = args = nil
      if gem =~ /(.*)-(\d+\.\d+\.\d+)$/
        gem, version = $1, $2
        grep = "^#{gem}.*#{version}"
        args = " --version #{version}"
      else
        grep = "^#{gem}"
      end
      if fails?("gem list #{gem} | grep '#{grep}'")
        banner "#{gem}..."
        run "gem install #{gem} #{args} --no-rdoc --no-ri"
        return true
      end
      false
    end

    # Returns the newest currently installed version of
    # the named gem or false if the gem is not installed
    def gem_version(name)
      spec_out = `gem specification #{name} 2> /dev/null`
      if !spec_out.empty?
        spec = Gem::Specification.from_yaml(spec_out)
        spec.version
      end
    end


    # Calculate the md5 checksum for a file
    def md5sum(path)
      digest, buf = Digest::MD5.new, ""
      File.open(path) do |f|
        while f.read(4096, buf)
          digest.update(buf)
        end
      end
      digest.hexdigest
    end

    private
   
  end
end