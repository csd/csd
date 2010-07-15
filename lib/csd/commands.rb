# encoding: utf-8
require 'pathname'
require 'ostruct'

module CSD
  # This class contains wrapper methods for standard file system operations. They are meant to be
  # a little bit more robust (e.g. raising no exceptions) and return elaborate feedback on their operation.
  # All of these methods, except for the +run+ method, are platform independent.
  #
  class Commands
    
    # The Process module is a collection of methods used to manipulate processes.
    # We use it to check whether we run as sudo or not by evaluating the uid of ths user (if it's 0 it's root)
    include Process
    
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
    def mkdir(target, params={})
      default_params = { :die_on_failure => true, :show_output => false }
      params = default_params.merge(params)
      target = target.pathnamify
      result = CommandResult.new
      if target.directory?
        # Don't do anything if the directory already exists
        result.already_existed = true
      else
        begin
          UI.info "Creating directory: #{target}".cyan
          # Try to create the directory
          target.mkpath unless Options.reveal
        rescue Errno::EACCES => e
          result.reason = "Cannot create directory (no permission): #{target}"
          params[:die_on_failure] ? UI.die(result.reason) : UI.error(result.reason)
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
    def cd(target, params={})
      default_params = { :die_on_failure => true, :show_output => false }
      params = default_params.merge(params)
      target = target.pathnamify
      result = CommandResult.new
      UI.info "cd #{target}".yellow
      if Options.reveal
        # We need to fake changing the directory in reveal mode.
        @pwd = target.to_s
        result.success = true
      else
        begin
          Dir.chdir(target)
          result.success = target.current_path?
        rescue Exception => e
          result.reason = "Cannot change to directory `#{target}´. Reason: #{e.message}"
          params[:die_on_failure] ? UI.die(result.reason) : UI.error(result.reason)
        end
      end
      result
    end
    
    # Copies one or several files to the destination
    #
    def copy(src, dest, params={})
      transfer(:copy, src, dest, params)
    end
    
    # Moves one or several files to the destination
    #
    def move(src, dest, params={})
      transfer(:move, src, dest, params)
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
    
    # Replaces all occurences of a pattern in a file.
    # In a block, it yields the Replacer class.
    # Otherwise it calls the replace function in the Replacer class. 
    #
    def replace(filepath, pattern='', substitution='', params={}, &block)
      params = pattern if pattern.is_a?(Hash)
      default_params = { :die_on_failure => true }
      params = default_params.merge(params)
      UI.info "Modifying contents of `#{filepath}´ as follows:".cyan
      Replacer.filepath = filepath
      if block_given?
        yield Replacer
      else
        Replacer.replace(pattern, substitution, params)
      end
    end
    
    # This class is yielded by the replace function in a block
    #
    class Replacer
      class << self
        attr_accessor :filepath
      end
      
      # Replaces all occurences of a pattern in a file
      #
      # ==== Returns
      #
      # This method returns a CommandResult object with the following values:
      #
      # [+success?+] +true+ if the replacement was successful, +nil+ if not.
      #
      def self.replace(pattern, substitution, params={})
        result = CommandResult.new
        default_params = { :die_on_failure => true }
        params = default_params.merge(params)
        begin
          UI.info "Replacing all occurences of `#{pattern}´ with `#{substitution}´".blue
          new_file_content = File.read(filepath).gsub(pattern, substitution)
          File.open(filepath, 'w+') { |file| file << new_file_content } unless Options.reveal
          result.success = true
        rescue Errno::ENOENT => e
          result.success = false
          result.reason = "Could not perform replace operation! #{e.message}"
          params[:die_on_failure] ? UI.die(result.reason) : UI.error(result.reason)
        end
        result
      end
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
      default_params = { :die_on_failure => true, :show_output => false }
      params = default_params.merge(params)
      cmd = cmd.to_s
      UI.info "Running command in #{pwd}".yellow
      UI.info cmd.cyan
      return '' if Options.reveal
      ret = ''
      IO.popen(cmd) do |stdout|
        stdout.each do |line|
          UI.info "       #{line}" unless params[:show_output]
          ret << line
        end
      end
      UI.die "The last command was unsuccessful." if params[:die_on_failure] and !$?.success?
      ret
    end
    
    private
    
    # The common backend for copy and move operations.
    #
    def transfer(action, src, dest, params={})
      default_params = { :die_on_failure => true }
      params = default_params.merge(params)
      result = CommandResult.new
      UI.info "#{action == :copy ? 'Copying' : 'Moving'} `#{src}´ to `#{dest}´".cyan
      begin
        FileUtils.send(action, src, dest) unless Options.reveal
        result.success = true
      rescue Exception => e
        result.success = false
        result.reason = "Could not perform #{action} operation! #{e.message}"
        params[:die_on_failure] ? UI.die(result.reason) : UI.error(result.reason)
      end
      result
    end
  
  end
  
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
  
end