#-- encoding: UTF-8

# Loading all files in the subdirectory `csd´
Dir[File.join(File.dirname(__FILE__), 'csd', '*.rb')].sort.each { |path| require "csd/#{File.basename(path, '.rb')}" }

# The CSD namespace is given to the entire gem.
# It stands for Communication Systems Design (see http://www.tslab.ssvl.kth.se/csd).
#
module CSD
  class << self
  
    # This String holds the name of the executable the user used to bootstrap this gem
    attr_reader :executable
  
    # This method "runs" the whole CSD gem, so to speak.
    #
    def bootstrap(options={})
      @executable = options[:executable]
      Options.parse!
      respond_to_incomplete_arguments
      UI.debug "#{self}.bootstrap initializes the task #{Options.action.to_s.enquote if Options.action} of the application #{Applications.current.name.to_s.enquote if Applications.current} now"
      Applications.current.instance.send("#{Options.action}".to_sym) if Applications.current
    end
  
    private
  
    # This method check the arguments the user has provided and terminates the AI with
    # some helpful message if the arguments are invalid.
    #
    def respond_to_incomplete_arguments
      if !Applications.current and ARGV.include?('update')
        # Updating the AI
        UI.info "Updating the AI to the newest version".green.bold
        Cmd.run "sudo gem update csd --no-ri --no-rdoc", :announce_pwd => false, :verbose => true
        exit!
      elsif !Applications.current and ARGV.include?('edge')
        UI.info "Updating the AI to the cutting-edge experimental version".green.bold
        Path.edge_tmp = Dir.mktmpdir
        Path.edge_file = File.join(Path.edge_tmp, 'edge.gem')
        if Cmd.download('http://github.com/downloads/csd/csd/edge.gem', Path.edge_file).success?
          Cmd.run "sudo gem install #{Path.edge_file} --no-ri --no-rdoc", :announce_pwd => false, :verbose => true
        else
          UI.info "Currently there is no edge version published.".green.bold
        end
        FileUtils.rm_r Path.edge_tmp
        exit!
      else
        choose_application unless Applications.current
        choose_action unless Options.valid_action?
      end
    end
  
    # This methods lists all available applications
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
      #UI.info '                For example:   '.green.bold + "#{executable} minisip".cyan.bold
      UI.separator
      UI.warn "You did not specify a valid application name."
      raise Error::Argument::NoApplication
    end

    # This methods lists all available actions for a specific application
    #
    def choose_action
      UI.separator
      UI.info "  Automated Installer assistance for #{Applications.current.human}".green.bold
      UI.separator
      UI.info "  The AI can assist you with the following tasks regarding #{Applications.current.human}: "
      OptionParser.new do |opts|
        opts.banner = ''
        actions = Applications.current.actions['public']
        actions << Applications.current.actions['developer'] if Options.developer
        actions.flatten.each { |action| opts.list_item(action.keys.first, action.values.first) }
        UI.info opts.help
      end
      UI.separator
      example_action = actions.flatten.keys.first
      UI.info '  To execute a task:   '.green.bold + "#{executable} [TASK] #{Applications.current.name}".cyan.bold + "          Example: #{executable} #{example_action} #{Applications.current.name}".dark
      UI.info '   For more details:   '.green.bold + "#{executable} help [TASK] #{Applications.current.name}".cyan.bold + "     Example: #{executable} help #{example_action} #{Applications.current.name}".dark
      UI.separator
      UI.warn "You did not specify a valid task name."
      raise Error::Argument::NoAction
    end

  end
end
