# Loading all files in CSD
Dir.glob(File.join(File.dirname(__FILE__), 'csd', '*.rb')) { |file| require file }

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
      define_root_path
      respond_to_incomplete_arguments
      Applications.current.instance.introduction
    end
    
    # This method chooses and holds the user interface instance
    #
    def ui
      @@ui ||= CLI.new
    end
    
    private
    
    def define_root_path
      if Options.path
        if File.directory?(Options.path)
          Path.root = File.expand_path(Options.path)
        else
          raise OptionsPathNotFound, "The path `#{Options.path}´ doesn't exist."
        end
      else
        Path.root = Options.temp ? Dir.mktmpdir : Dir.pwd
      end
    end
    
    def respond_to_incomplete_arguments
      if Options.help
        UI.info Options.helptext
        exit
      end
      
      introduction unless Options.application
      
    end
    
    def introduction
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
      UI.info '                         or:   '.green.bold + "#{executable} help".cyan.bold
      UI.separator
      exit
    end

  end
end
