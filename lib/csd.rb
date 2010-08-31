#-- encoding: UTF-8
require 'net/http'

# Loading all files in the subdirectory `csd´
Dir[File.join(File.dirname(__FILE__), 'csd', '*.rb')].sort.each { |path| require "csd/#{File.basename(path, '.rb')}" }

# The CSD namespace is given to the entire gem.
# It stands for Communication Systems Design (see http://www.tslab.ssvl.kth.se/csd).
#
module CSD
  class << self
  
    # This String holds the name of the executable the user used to execute/bootstrap this gem.
    # It is useful for showing example commands to the end-user, such as "Please type: ai install minisip".
    # Because the name of the executable might change after some time. Currently, +ai+ and +ttai+ are
    # supported executables.
    attr_reader :executable
  
    # This method "runs" the whole CSD gem, so to speak.
    #
    # ==== Options
    #
    # The following options can be passed as a hash.
    #
    # [+:executable+] A String which holds the name of the exectuable that was used to call this method (default: <tt>[EXECUTABLE]</tt>).
    #
    def bootstrap(options={})
      # Storing the important options into instance variables
      @executable = options[:executable] || '[EXECUTABLE]'
      # Reading the command-line arguments
      Options.parse!
      # Intercepting and processing AI-internal commands such as "ai update" and "ai edge"
      respond_to_internal_ai_options
      # Ensure that the chosen action, application (and optionally the scope) are valid
      respond_to_incomplete_arguments
      UI.debug "#{self}.bootstrap initializes the task #{Options.action.to_s.enquote if Options.action} of the application #{Applications.current.name.to_s.enquote if Applications.current} now"
      # Passing on the desired action to the instance of the chosen application module (e.g. passing on "install" to the "MiniSIP" module)
      Applications.current.instance.send("#{Options.action}".to_sym) if Applications.current
    end
  
    private
    
    # This method is the first in the chain of processing the command-line arguments. It will react to
    # AI-internal commands such as "update" or "edge".
    #
    def respond_to_internal_ai_options
      # If an application was chosen, this is clearly not an internal AI functionality which the user requested
      return if Applications.current
      # Other than that, react to some predefined commands
      if ARGV.include?('update')
        update_ai_using_rubygems
      elsif ARGV.include?('edge')
        update_ai_to_cutting_edge
      end
    end
    
    # Updating the AI via the internal RubyGems mechanism (i.e. <tt>gem update</tt>).
    # The AI will quit with status code 0 after the operation was successful.
    #
    def update_ai_using_rubygems
      UI.info "Updating the AI to the newest version".green.bold
      Cmd.run "sudo gem update csd --no-ri --no-rdoc", :announce_pwd => false, :verbose => true
      exit! # with status code 0
    end
    
    # This method is used to conveniently update the AI without officially publishing it on RubyGems.
    # This can be handy when testing many things on many machines in a very short amount of time :)
    # Basically this function will download a list of predefined locations on where the cutting-edge
    # gem of the AI can be obtained from. Then it will go through each location in order to download
    # and install the edge version. The AI quits after the first successful download+installation attempt.
    #
    def update_ai_to_cutting_edge
      UI.info "Updating the AI to the cutting-edge experimental version".green.bold
      # Create a temporary working directory
      Path.edge_tmp = Dir.mktmpdir
      Path.edge_file = File.join(Path.edge_tmp, 'edge.gem')
      # Retrieve list of possible locations for edge versions. Note that you can just modify that list to add your own locations
      # You can modify the list at http://github.com/csd/csd/downloads but note that the Amazon G3 cache (used by Github) takes about 12 hours to refresh the file, though!
      for location in Net::HTTP.get_response(URI.parse('http://cloud.github.com/downloads/csd/csd/edge.txt')).body.split.each do
        # See if there is a downloadable edge version at this location. If not, move on to the next location
        next unless Cmd.download(location, Path.edge_file).success?
        # If the download was successful here, let's update the AI from that downloaded gem-file and quit the loop
        updated = Cmd.run("sudo gem install #{Path.edge_file} --no-ri --no-rdoc", :announce_pwd => false, :verbose => true).success?
        break
      end
      UI.info "Currently there is no edge version published.".green.bold unless updated
      # Cleaning up the temporary directory
      FileUtils.rm_r Path.edge_tmp
      exit! # with status code 0
    end
    
    # This method check the arguments the user has provided and terminates the AI with
    # some helpful message if the arguments are invalid.
    #
    def respond_to_incomplete_arguments
      choose_application unless Applications.current
      choose_action      unless Options.valid_action?
      choose_scope       if Options.scope and not Options.valid_scope?
    end
  
    # This methods lists all applications that the AI currently supports.
    #
    def choose_application
      UI.separator
      UI.info '  Welcome to the Automated Installer.'.green.bold
      UI.separator
      UI.info '  The AI can assist you with the following applications: '
      OptionParser.new do |opts|
        opts.banner = ''
        Applications.all { |app| opts.list_item(app.name, app.description) }
        UI.info opts.help
      end
      UI.separator
      UI.info '  For more information type:   '.green.bold + "#{executable} [APPLICATION NAME]".cyan.bold + "     Example: #{executable} minisip".dark
      UI.separator
      UI.warn "You did not specify a valid application name."
      raise Error::Argument::NoApplication
    end

    # This methods lists all available actions for the currently selected application.
    #
    def choose_action
      UI.separator
      UI.info "  Automated Installer assistance for #{Applications.current.human}".green.bold
      UI.separator
      UI.info "  The AI can assist you with the following tasks regarding #{Applications.current.human}:"
      OptionParser.new do |opts|
        opts.banner = ''
        actions = Applications.current.actions['public']
        actions << Applications.current.actions['developer'] if Options.developer
        actions.flatten.each { |action| opts.list_item(action.keys.first, action.values.first) }
        UI.info opts.help
      end
      UI.separator
      example_action = Options.actions_names.empty? ? 'install' : Options.actions_names.first
      UI.info '  To execute a task:   '.green.bold + "#{executable} [TASK] #{Applications.current.name}".cyan.bold + "          Example: #{executable} #{example_action} #{Applications.current.name}".dark
      UI.info '   For more details:   '.green.bold + "#{executable} help [TASK] #{Applications.current.name}".cyan.bold + "     Example: #{executable} help #{example_action} #{Applications.current.name}".dark
      UI.separator
      UI.warn "You did not specify a valid task name."
      raise Error::Argument::NoAction
    end
    
    # This methods lists all available scopes for the currently selected application and action.
    #
    def choose_scope
      UI.separator
      UI.info "  Automated Installer assistance to #{Options.action} #{Applications.current.human}".green.bold
      UI.separator
      UI.info "  The AI can #{Options.action} the following #{Applications.current.human} components:"
      OptionParser.new do |opts|
        opts.banner = ''
        scopes = Applications.current.scopes(Options.action)
        scopes.flatten.each { |scope| opts.list_item(scope.keys.first, scope.values.first) }
        UI.info opts.help
      end
      UI.separator
      example_scope = Options.scopes_names.empty? ? 'myscope' : Options.scopes_names.first
      UI.info '  To choose all components:   '.green.bold + "#{executable} #{Options.action} #{Applications.current.name}".cyan.bold + "                      Example: #{executable} #{Options.action} #{Applications.current.name}".dark
      UI.info '   To choose one component:   '.green.bold + "#{executable} #{Options.action} #{Applications.current.name} [COMPONENT]".cyan.bold + "          Example: #{executable} #{Options.action} #{Applications.current.name} #{example_scope}".dark
      UI.separator
      UI.warn "You did not specify a valid scope."
      raise Error::Argument::NoAction
    end

  end
end
