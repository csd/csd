# encoding: utf-8
require 'csd/application/default/base'

module CSD
  # This namespace holds all individual application Modules
  #
  module Application
  
    # This is the root class of all Applications
    #
    module Default
      
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



