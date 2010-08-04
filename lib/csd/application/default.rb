# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'
require 'yaml'

module CSD
  # This namespace holds all individual application Modules
  #
  module Application
  
    # This is the root class of all Applications
    #
    module Default
      
      # This method must be overwritten by the actual application module. It holds the application instance
      # which was chosen for this operating system.
      #
      def instance
        raise Error::Application::NoInstanceMethod, "The application module must define an method called `instance´."
      end
      
      def name
        self.to_s.demodulize.underscorize
      end
    
      def description
        about.description
      end
    
      def human
        about.human
      end
    
      def actions
        about.actions
      end
    
      def scopes(action)
        # TODO: about.scopes[:action]
        []
      end
      
      # This method will look for application and task specific optionsfiles of the current application module.
      # It returns the Ruby code in a +String+ to be eval'd by the OptionsParser.
      # If there are no files in myapplication/options, an empty +String+ is returned instead.
      #
      def options(action='')
        result = []
        ["common.rb", "#{action}.rb"].each do |filename|
          file = File.join(Path.applications, name, 'options', filename)
          result << File.read(file) if File.file?(file)
        end
        default_options + result.join("\n")
      end
      
      # Comes in handy for the test suite
      #
      def default_options(action='')
        result = []
        ["common_defaults.rb", "#{action}_defaults.rb"].each do |filename|
          file = File.join(Path.applications, name, 'options', filename)
          result << File.read(file) if File.file?(file)
        end
        result.join("\n")
      end
    
      protected
    
      def about
        about_file = File.join(Path.applications, name, 'about.yml')
        OpenStruct.new YAML.load_file(about_file)
      end
    
    end
  end
end



