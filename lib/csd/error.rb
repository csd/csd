# -*- encoding: UTF-8 -*-

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
      class NoAction < CSDError; status_code(12); end
      class InvalidOption < CSDError; status_code(50); end
    end
    
    # Errors in this module are raised by the Command module
    #
    module Command
      class RunFailed < CSDError; status_code(60); end
      class CdFailed < CSDError; status_code(61); end
      class CopyFailed < CSDError; status_code(62); end
      class MoveFailed < CSDError; status_code(63); end
      class ReplaceFailed < CSDError; status_code(64); end
      class MkdirFailed < CSDError; status_code(65); end
    end
    
    # Errors in this module are related to the Application Module Framework
    #
    module Application
      class OptionsSyntax < CSDError; status_code(100); end
      class NoInstanceMethod < CSDError; status_code(101); end
    end
  
  end
end