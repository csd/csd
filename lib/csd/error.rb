module CSD
  # In this module we will keep all types of errors in a readable hierarchy
  #
  module Error
    
    # All Exceptions raised by CSD must be children of this class. 
    #
    class CSDError < StandardError
      def self.status_code(code = nil)
        return @code unless code
        @code = code
      end
    
      def status_code
        self.class.status_code
      end
    end
    
    # Errors in this module are related to command-line options
    #
    module Argument
      class NoApplication < CSDError; status_code(11); end
    end
    
    module Application
      class OptionsSyntax < CSDError; status_code(200); end
    end
  
  end
end