# Defining application wide constants
#ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))  # Absolute root directory of this gem
#Version   = File.read(File.join(ROOT_PATH, 'VERSION'))                 # Version number of this gem

# Loading all files in csd
Dir.glob(File.join(File.dirname(__FILE__), 'csd', '*.rb')) { |file| require file }

# This namespace is given to the entire CSD gem.
#
module CSD
  class << self

    def bootstrap
      Options.parse
      puts 'here:'
      puts Options.action.inspect
    end
    
    
    include Gem::UserInteraction
    
    attr_reader :options, :path, :application
    
    def initialize
      @options     = Options.parse
      #puts @options.inspect
      @path        = path_struct
      validate_arguments
      @application = initialize_application
      @application.introduction
      self
    end
    
    def path_struct
      path = OpenStruct.new
      if options.path
        if File.directory?(options.path)
          path.root = File.expand_path(options.path)
        else
          say "The path ´#{options.path}´ doesn't exist."
          exit
        end
      else
        path.root = options.temp ? Dir.mktmpdir : Dir.pwd
      end
      path
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
    
    def initialize_application
      directory_name = ARGV.second.underscore
      begin
        require File.join(File.join(Applications.path, "#{directory_name}"), 'init.rb')
        "CSD::Application::#{directory_name.camelize}::Init".constantize.application(:options => @options, :path => @path)
      rescue LoadError
        say "Unknown application: #{directory_name}"
        exit
      end
    end

  end
end
