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
      Applications.current.instance.introduction
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
      
      
      
      #if Options.help
      #  UI.info Options.helptext
      #  exit
      #end
      #
      #introduction unless Options.application
      
    end
    
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
      raise Error::Argument::NoApplication
    end

  end
end
