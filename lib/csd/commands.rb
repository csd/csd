require 'pathname'
require 'ostruct'
require 'active_support'

module CSD
  module Commands
    
    class CommandResult < OpenStruct
      def method_missing(meth, *args, &block)
        # Convenience accessor self.something? => self.something
        meth.to_s.ends_with?('?') ? self.send(meth.to_s.chop.to_sym, *args, &block) : super
      end
    end
    
    # Creates a directory.
    #
    #   CommandResult values:
    #   success         => true/nil    # Whether the directory exists after the operation
    #   already_existed => true/nil    # Whether the directory existed before the operation
    #   writable        => true/nil    # Whether the directory is writable (returns nil if the directory doesn't exist)
    #   
    def mkdir(target)
      target = Pathname.new(target) unless target.is_a?(Pathname)
      result = CommandResult.new
      if target.directory?
        # Don't say anything if the directory already exists
        result.already_existed = true
      else
        begin
          say "Creating directory: #{target}".cyan unless options.quiet
          target.mkpath unless options.dry
        rescue Errno::EACCES => e
           say "Cannot create directory (no permission): #{target}".red unless options.quiet
           return result
        end
      end
      result.success  = (target.directory? or options.dry)
      result.writable = (target.writable? or options.dry)
      result
    end
    
    def cd(target)
      target = Pathname.new(target) unless target.is_a?(Pathname)
      if target.directory? or options.dry
        say "cd #{target}".yellow
        success = true
      elsif target.exists?
        say "Cannot change to directory because it exists but is not a directory: #{target}".red
        return false
      else
        success = mkdir(target)
      end
      Dir.chdir(target) if success and !options.dry
    end
    
    def sh(command)
      
    end
    
    
    def test_command(*args)
      say "Testing command for success: #{args.join(' ')}".yellow
      system(*args)
    end
    
    def run_command(cmd, params={})
      default_params = { :exit_on_failure => true }
      params = default_params.merge(params)
      say "Running command in #{Dir.pwd}".yellow unless options.quiet
      say cmd.cyan
      ret = ''
      unless options.dry
        IO.popen(cmd) do |stdout|
          stdout.each do |line|
            say "       #{line}"
            ret << line
          end
        end
      end
      exit_if_last_command_had_errors if params[:exit_on_failure]
      ret
    end
    
    def exit_if_last_command_had_errors
      unless $?.success?
        say "The last command was unsuccessful.".red unless options.quiet
        exit
      end
    end
    
    
    def say(something='')
    end

    def log(msg="")
      say msg.yellow unless options.silent
    end
    
    # Dummy to be overwritten by real options
    def options
      OpenStruct.new
    end
  
  end
end