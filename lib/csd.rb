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
      UI.debug "#{self}.bootstrap initializes the task #{Options.action.enquote} of the application #{Applications.current.name.to_s.enquote} now"
      Applications.current.instance.send("#{Options.action}".to_sym)
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
        exit # The only smooth status code 0 exit in this whole application :)
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
      UI.info '  To execute a task:   '.green.bold + "#{executable} [TASK] #{Applications.current.name}".cyan.bold + "          Example: #{executable} compile minisip".dark
      UI.info '   For more details:   '.green.bold + "#{executable} help [TASK] #{Applications.current.name}".cyan.bold + "     Example: #{executable} help compile minisip".dark
      UI.separator
      UI.warn "You did not specify a valid task name."
      raise Error::Argument::NoAction
    end

  end
end
