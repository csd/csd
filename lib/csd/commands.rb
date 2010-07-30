# -*- encoding: UTF-8 -*-
require 'pathname'
require 'ostruct'
require 'open3'

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
      default_params = { :die_on_failure => true, :internal => false }
      params = default_params.merge(params)
      target = target.pathnamify
      result = CommandResult.new
      if target.directory?
        # Don't do anything if the directory already exists
        result.already_existed = true
      else
        begin
          UI.info "Creating directory: #{target}".cyan unless params[:internal]
          # Try to create the directory
          target.mkpath unless Options.reveal
        rescue Errno::EACCES => e
          result.reason = "Cannot create directory (no permission): #{target}"
          params[:die_on_failure] ? raise(CSD::Error::Command::MkdirFailed, result.reason) : UI.error(result.reason)
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
      default_params = { :die_on_failure => true, :internal => false }
      params = default_params.merge(params)
      target = target.pathnamify
      result = CommandResult.new
      UI.info "cd #{target}".yellow unless params[:internal]
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
          params[:die_on_failure] ? raise(CSD::Error::Command::CdFailed, result.reason) : UI.error(result.reason)
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
      begin
        if Options.reveal
          @pwd ||= Dir.pwd
        else
          Dir.pwd
        end
      rescue Errno::ENOENT => e
        UI.debug "The current pwd could not be located. Was the directory removed?"
        nil
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
          UI.info "   Modifying".yellow
          UI.info "   `#{pattern}´".blue
          UI.info "   to".yellow
          UI.info "   `#{substitution.to_s.gsub("\n", "\n    ")}´".white
          new_file_content = File.read(self.filepath).gsub(pattern.to_s, substitution.to_s)
          File.open(self.filepath, 'w+') { |file| file << new_file_content } unless Options.reveal
          result.success = true
        rescue Errno::ENOENT => e
          if Options.reveal
            result.success = true
            return result
          end
          result.success = false
          result.reason = "Could not perform replace operation! #{e.message}"
          params[:die_on_failure] ? raise(CSD::Error::Command::ReplaceFailed, result.reason) : UI.error(result.reason)
        end
        result
      end
    end
    
    # Runs a command on the system.
    #
    # ==== Options
    #
    # The following options can be passed as a hash.
    #
    # [+:die_on_failure+] If the exit code of the command was not 0, exit the CSD application (default: +true+).
    # [+:announce_pwd+] Before running the command, announce in which path the command will be executed (default: +true+).
    # [+:verbose+] Instead of printing just one `.´ per command output line, print the full command output lines (default: +false+).
    # [+:internal+] If this parameter is +true+, there will be no output what-so-ever for running this command. (default: +false+).
    #
    # ==== Returns
    #
    # This method returns a CommandResult object with the following values:
    #
    # [+success?+] +true+ if the command was successful, +nil+ if not.
    # [+output?+] The command's output as a +String+ (with newline delimiters). Note that the exit code can be accessed via the global variable <tt>$?</tt>
    #
    def run(cmd, params={})
      default_params = { :die_on_failure => true, :announce_pwd => true, :verbose => Options.verbose, :internal => false, :force_in_reveal => false }
      params = default_params.merge(params)
      result = CommandResult.new
      cmd = cmd.to_s
      UI.info "Running command in #{pwd}".yellow if params[:announce_pwd] and !params[:internal]
      UI.info cmd.cyan unless params[:internal]
      if Options.reveal and !params[:force_in_reveal]
        result.success = true
        return result
      end
      result.output = ''
      STDOUT.sync = true # Because we redirect stderr into stdout to get the output and it needs to be flushing automatically
      IO.popen("#{cmd} 2>&1") do |pipe| # IO redirection is performed using operators
        pipe.sync = true
        while line = pipe.gets
          unless params[:internal] # No output needed for the unit-tests and AI-internal use
            params[:verbose] ? UI.info("       #{line}") : UI.indicate_activity
          end
          result.output << line
        end
      end
      UI.separator unless params[:verbose] or params[:internal] # i.e. if dots are concatenated in the same line, we should create a new line after them
      result.status = $?
      result.success = $?.success?
      if params[:die_on_failure] and !result.success
        UI.info result.output unless params[:verbose] # In verbose mode, we don't need to repeat the unsuccessful command's output
        raise CSD::Error::Command::RunFailed, "The last command was unsuccessful." 
      end
      result
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
        if params[:die_on_failure]
          case action
            when :copy then raise CSD::Error::Command::CopyFailed, result.reason
            when :move then raise CSD::Error::Command::MoveFailed, result.reason
          end
        else
          UI.error result.reason
        end
      end
      result
    end
    
    # Clones the master branch of a repository using +git+. +name+ is a +String+ used for UI outputs,
    # +repository+ is the URL/path to the repository, +destination+ is an absolute or relative
    # path to where the repository should be downloaded to.
    #
    # This command will not do anything if the destination already exists.
    #
    def git_clone(name, repository, destination)
      result = CommandResult.new
      destination = destination.pathnamify
      if destination.directory? and !Options.reveal
        UI.warn "Skipping #{name} download, because the directory already exists: #{destination.enquote}"
        result.already_exists = true
        return result
      end
      unless destination.parent.writable? or Options.reveal
        UI.error "Could not download #{name} (no permission): #{destination.enquote}"
        result.no_permission = true
        return result
      end
      UI.info "Downloading #{name} to #{destination.enquote}".green.bold
      # We will simply return the CommandResult of the run-method.
      Cmd.run("git clone #{repository} #{destination}", :announce_pwd => false)
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