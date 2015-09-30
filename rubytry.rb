

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





args = [:name, :description, :start_date, :end_date]


run_capture(puts , *args)


