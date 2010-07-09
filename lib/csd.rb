# Loading all files in CSD
Dir.glob(File.join(File.dirname(__FILE__), 'csd', '*.rb')) { |file| require file }

# This namespace is given to the entire CSD gem.
#
module CSD
  class << self

    include Gem::UserInteraction
    
    attr_reader :executable
    
    def bootstrap(options={})
      @executable = options[:executable]
      Options.parse!
      define_root_path
      validate_arguments
      Applications.current.instance.introduction
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
          say "Please specify an ACTION or get more help with `" + "#{executable} --help".green.bold + "´"
          exit
        when 1
          say "Please specify an APPLICATION or get more help with `" + "#{executable} --help".green.bold + "´"
          exit
      end
    end

  end
end
