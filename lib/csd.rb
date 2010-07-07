# Loading all files in CSD
Dir.glob(File.join(File.dirname(__FILE__), 'csd', '*.rb')) { |file| require file }

# This namespace is given to the entire CSD gem.
#
module CSD
  class << self

    include Gem::UserInteraction
    
    def bootstrap
      Options.parse!
      define_root_path
      ui.ask('yo?')
    end
    
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
    
    def validate_arguments
      case ARGV.size
        when 0
          say "Please specify an ACTION or get more help with `" + "csd --help".magenta + "´"
          exit
        when 1
          say "Please specify an APPLICATION or get more help with `" + "csd --help".magenta + "´"
          exit
      end
      #if Applications.valid?()
      
    end

  end
end
