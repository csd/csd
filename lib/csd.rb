# encoding: utf-8
# Loading all files in CSD
require 'csd/error'
require 'csd/options'

# The CSD namespace is given to the entire gem.
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
      Applications.current.instance.send("#{Options.action}!".to_sym)
    end
    
    # This method chooses and holds the user interface instance
    #
    def ui
      @@ui ||= CLI.new
    end
    
    private
    
    # This method check the arguments the user has provided and terminates the AI with
    # some helpful message if the arguments are invalid.
    #
    def respond_to_incomplete_arguments
      choose_application unless Applications.current
      choose_action unless Options.valid_action?
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
      UI.info '  For more information type:   '.green.bold + "#{executable} [APPLICATION NAME]".cyan.bold
      UI.info '                For example:   '.green.bold + "#{executable} minisip".cyan.bold
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
        actions = Applications.current.actions[:public]
        actions << Applications.current.actions[:developer] if Options.developer
        actions.flatten.each { |action| opts.list_item(action.keys.first, action.values.first) }
        UI.info opts.help
      end
      UI.separator
      UI.info '  To execute the task:   '.green.bold + "#{executable} [TASK] #{Applications.current.name}".cyan.bold
      UI.info '     For more details:   '.green.bold + "#{executable} help [TASK] #{Applications.current.name}".cyan.bold
      UI.info '              Example:   '.green.bold + "#{executable} help install #{Applications.current.name}".cyan.bold
      UI.separator
      UI.warn "You did not specify a valid task name."
      raise Error::Argument::NoAction
    end

  end
end
