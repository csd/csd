module CSD
  # This namespace holds all individual application Modules
  #
  module Application
    
    # This is the root class of all Applications
    #
    class Base
      
      #include Commands
      include ::Gem::UserInteraction
      
      attr_reader :after_build, :before_build # Dummies to be overwritten by methods
      
      # introduction
      
      def option_parser
        
      end

      def to_s
        human
      end
      
      # This returns all supported actions of this application module
      #
      def actions
        YAML.load_file(File.join(Path.applications, 'actions.yml'))
      end
      
      # This returns all supported scopes of this application module
      #
      def scopes(action)
        case action.to_sym
          when :install
            [{'(none)' => 'Installs the application as recommended'}, {'configuration' => 'Applies a remote configuration to an already installed application'}]
        end
      end
      
    end
  end
end



