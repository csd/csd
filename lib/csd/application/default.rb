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
        options_dir      = File.join(Path.applications, name, 'options')
        common_file      = File.join(options_dir, "common.rb")
        specific_file    = File.join(options_dir, "#{action}.rb")
        common_options   = File.file?(common_file) ? File.read(common_file) : ''
        specific_options = File.file?(specific_file) ? File.read(specific_file) : ''
        specific_options + common_options
      end
    
      protected
    
      def about
        about_file = File.join(Path.applications, name, 'about.yml')
        OpenStruct.new YAML.load_file(about_file)
      end
    
    end
  end
end



