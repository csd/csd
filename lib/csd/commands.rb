require 'active_support/core_ext'
require 'pathname'
require 'ostruct'

module CSD
  # This module contains wrapper methods for standard file system commands. They are meant to be
  # a little bit more robust (e.g. raising no exceptions) and return elaborate feedback on their operation.
  #
  module Commands
    
    # The Process module is a collection of methods used to manipulate processes.
    # We use it to check whether we run as sudo or not by evaluating the uid of ths user (if it's 0 it's root)
    include Process
    
    # Objects of this class can be returned by Commands. Since it is an OpenStruct object,
    # it can contain an arbritary number of values.
    #
    class CommandResult < OpenStruct
      
      # This creates an convenient, read-only accessor for the OpenStruct object values.
      # It simply maps methods that end with a <tt>?</tt> to the same method without <tt>?</tt>.
      #
      # ==== Examples
      #
      #   command_result.something? # => command_result.something
      #
      def method_missing(meth, *args, &block)
        meth.to_s.ends_with?('?') ? self.send(meth.to_s.chop.to_sym, *args, &block) : super
      end
      
    end
    
    # Creates a directory recursively.
    #
    # ==== Returns
    #
    # This method returns a CommandResult object with the following values:
    #
    # [+success?+]         +true+ if the directory exists after the operation, +nil+ if not.
    # [+already_existed?+] +true+ if the directory existed before the operation, +nil+ if not.
    # [+writable?+]        +true+ if the directory is writable, +false+ if not, +nil+ if the directory doesn't exist.
    #
    # ==== Examples
    #
    #  result = mkdir('foo')    # => #<CommandResult...>
    #  result.success?          # => true
    #  result.already_existed?  # => false
    #
    #  puts "I created a directory" if mkdir('bar').success?
    #
    #  mkdir('i/can/create/directories/recursively')
    #
    def mkdir(target)
      target = target.pathnamify
      result = CommandResult.new
      if target.directory?
        # Don't say anything if the directory already exists
        result.already_existed = true
      else
        begin
          say "Creating directory: #{target}".cyan unless options.quiet
          # Try to create the directory
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
    
    # Changes the current directory.
    #
    # ==== Returns
    #
    # This method returns a CommandResult object with the following values:
    #
    # [+success?+] +true+ if pwd is where it was requested to be after the operation, +nil+ if not.
    #
    def cd(target)
      target = target.pathnamify
      result = CommandResult.new
      if target.directory? or options.dry
        say "cd #{target}".yellow
        Dir.chdir(target)
      elsif target.exist?
        say "Cannot change to directory because it exists but is not a directory: #{target}".red
      end
      result.success = (target.current_path? or options.dry)
      result
    end
    
    # Runs a command on the system.
    #
    # ==== Returns
    #
    # The command's output as an +Array+. Note that the exit code can be accessed via the global variable <tt>$?</tt>
    #
    # ==== Options
    #
    # The following options can be passed as a hash.
    #
    # [+:exit_on_failure+] If the exit code of the command was not 0, exit the CSD application.
    #
    #
    def sh(cmd, params={})
      default_params = { :exit_on_failure => true }
      params = default_params.merge(params)
      say "Running command in #{Dir.pwd}".yellow unless options.silent
      say cmd.cyan
      ret = ''
      unless options.dry
        IO.popen(cmd) do |stdout|
          stdout.each do |line|
            say "       #{line}" if options.verbose
            ret << line
          end
        end
      end
      exit_if_last_command_had_errors if params[:exit_on_failure]
      ret
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
      unless $?.try(:success?) or options.dry
        say "The last command was unsuccessful.".red unless options.quiet
        exit
      end
    end
    
    # Dummy to be overwritten by real options
    def options
      Options
    end
  
  end
end