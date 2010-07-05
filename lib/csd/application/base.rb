module CSD
  # This namespace holds all individual application Modules
  #
  module Application
    
    # This is the root class of all Applications
    #
    class Base
      
      #include Commands
      include Gem::UserInteraction
      
      attr_reader :after_build, :before_build # Dummies to be overwritten by methods
      
      # introduction
      
      def options_file
        File.join(path, 'options', 'options.rb')
      end

      def to_s
        human
      end
      
    end
  end
end



