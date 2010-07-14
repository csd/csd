# encoding: utf-8
require 'pathname'
require 'ostruct'

module CSD
  # This module contains wrapper methods for standard file system operations. They are meant to be
  # a little bit more robust (e.g. raising no exceptions) and return elaborate feedback on their operation.
  # All of these methods, except for the +run+ method, are platform independent.
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
        # Don't do anything if the directory already exists
        result.already_existed = true
      else
        begin
          UI.info "Creating directory: #{target}".cyan
          # Try to create the directory
          target.mkpath unless (Options.dry or Options.reveal)
        rescue Errno::EACCES => e
           UI.error "Cannot create directory (no permission): #{target}"
           return result
        end
      end
      result.success  = (target.directory? or Options.reveal)
      result.writable = (target.writable? or Options.reveal)
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
      if target.directory? or Options.reveal
        UI.info "cd #{target}".yellow
        if Options.reveal
          @pwd = target.to_s
        else
          Dir.chdir(target)
        end
      elsif target.exist?
        UI.error "Cannot change to directory because it exists but is not a directory: #{target}".red
      end
      result.success = (target.current_path? or Options.reveal)
      result
    end
    
    # Copies one or several files to the destination
    #
    def copy(src, dest)
      begin
        UI.info "Copying `#{src}´ to `#{dest}´".cyan
        FileUtils.cp(src, dest) unless (Options.dry or Options.reveal)
        true
      rescue Exception => e
        nil
      end
    end
    
    # Moves one or several files to the destination
    #
    def move(src, dest)
      begin
        UI.info "Moving `#{src}´ to `#{dest}´".cyan
        FileUtils.mv(src, dest) unless (Options.dry or Options.reveal)
        true
      rescue Exception => e
        nil
      end
    end
    
    # This returns the current pwd. However, it will return a fake result if we are in reveal-commands-mode.
    #
    def pwd
      if Options.reveal
        @pwd ||= Dir.pwd
      else
        Dir.pwd
      end
    end
    
    # Replaces all occurences of a pattern in a file
    #
    # ==== Returns
    #
    # This method returns a CommandResult object with the following values:
    #
    # [+success?+] +true+ if the replacement was successful, +nil+ if not.
    #
    def replace(filepath, pattern, substitution)
      result = CommandResult.new
      begin
        UI.info "Modifying contents of `#{filepath}´ as follows:".blue
        UI.info "  (Replacing all occurences of `#{pattern}´ with `#{substitution}´)".blue
        new_file_content = File.read(filepath).gsub(pattern, substitution)
        File.open(filepath, 'w+') { |file| file << new_file_content } unless (Options.dry or Options.reveal)
      rescue Errno::ENOENT => e
        result.success = false
      end
      result.success = true if Options.reveal
      result
    end
    
    # Runs a command on the system.
    #
    # ==== Returns
    #
    # The command's output as a +String+ (with newline delimiters). Note that the exit code can be accessed via the global variable <tt>$?</tt>
    #
    # ==== Options
    #
    # The following options can be passed as a hash.
    #
    # [+:exit_on_failure+] If the exit code of the command was not 0, exit the CSD application.
    #
    def run(cmd, params={})
      cmd = cmd.to_s
      default_params = { :die_on_failure => true, :silent => false }
      params = default_params.merge(params)
      unless params[:silent]
        UI.info "Running command in #{pwd}".yellow
        UI.info cmd.cyan
      end
      return '' if Options.reveal or Options.dry
      ret = ''
      IO.popen(cmd) do |stdout|
        stdout.each do |line|
          UI.info "       #{line}" unless params[:silent]
          ret << line
        end
      end
      die_if_last_command_had_errors if params[:exit_on_failure]
      ret
    end
    
    def die_if_last_command_had_errors
      UI.die "The last command was unsuccessful." unless $?.try(:success?)
    end
  
  end
  
  # Having a class to include all command modules
  #
  class CommandsInstance
    include Commands
  end
  
  # Wrapping the CommandsInstance class
  #
  class Cmd
    COMMANDS = %w{ mkdir cd run replace copy move }
    
    def self.instance
      @@instance ||= CommandsInstance.new
    end
    
    def self.method_missing(meth, *args, &block)
      COMMANDS.include?(meth.to_s) ? instance.send(meth, *args, &block) : super
    end
  end
  
end