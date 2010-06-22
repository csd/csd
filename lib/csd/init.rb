# Include all files in the same directory
Dir.glob(File.join(File.dirname(__FILE__), '*.rb')) { |file| require file }
require File.join(File.dirname(__FILE__), 'applications', 'base')

require 'ostruct'
require 'tmpdir'
require 'active_support/core_ext'

# This namespace is given to the entire CSD gem.
#
module Csd
  # On initialization, this class bootstraps and runs the CSD gem.
  # The initialization is most likely be done by the `csd´ executable.
  #
  class Init
    
    include Gem::UserInteraction
    
    attr_reader :gem_version, :options, :path, :application
    
    def initialize
      @options     = Options.parse
      @path        = path_struct
      @gem_version = File.read(File.join(path.gem_root, 'VERSION'))
      validate_arguments
      @application = initialize_application
      @application.introduction
      self
    end
    
    def path_struct
      path = PathContainer.new
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
          say "Please specify an action."
          exit
        when 1
          say "Please specify an application."
          exit
      end
    end
    
    def initialize_application
      directory_name = ARGV.second.underscore
      begin
        require File.join(File.join(path.applications, "#{directory_name}"), 'init.rb')
        "Csd::Application::#{directory_name.camelize}::Init".constantize.application(:gem_version => @gem_version, :options => @options, :path => @path)
      rescue LoadError
        say "Unknown application: #{directory_name}"
        exit
      end
    end
    
  end
end
