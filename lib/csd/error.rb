# -*- encoding: UTF-8 -*-

module CSD
  # In this module we will keep all types of errors in a readable hierarchy.
  # The application modules are assigned the following individual error ranges:
  #
  # * +minisip+ has been assigned error status codes 200-280
  # * +decklink+ has been assigned error status codes 280-299
  # * +graphics+ has been assigned error status codes 300-349
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
    
    # Errors in this module are caused by internal AI failures.
    #
    module Internal
      # Somebody tried to run the CSD::Extensions::Core::Pathname.pathnamify method on +nil+. This probably happened in the test-suite when a +Path+ is not set.
      class PathnamifyingNil < CSDError; status_code(1000); end
    end
    
    # Errors in this module are related to command-line options
    #
    module Argument
      # The <tt>--help</tt> parameter was given, thus the AI quitted after showing the help.
      class HelpWasRequested    < CSDError; status_code(2); end
      # The <tt>--version</tt> parameter was given, thus the AI quitted after showing the AI version number.
      class VersionWasRequested < CSDError; status_code(3); end
      class NoApplication       < CSDError; status_code(11); end
      class NoAction            < CSDError; status_code(12); end
      class InvalidOption       < CSDError; status_code(50); end
    end
    
    # Errors in this module are raised by the Command module
    #
    module Command
      class RunFailed     < CSDError; status_code(60); end
      class CdFailed      < CSDError; status_code(61); end
      class CopyFailed    < CSDError; status_code(62); end
      class MoveFailed    < CSDError; status_code(63); end
      class ReplaceFailed < CSDError; status_code(64); end
      class MkdirFailed   < CSDError; status_code(65); end
      class TouchAndReplaceContentFailed < CSDError; status_code(66); end
    end
    
    # Errors in this module are related to the Application Module Framework
    #
    module Application
      class OptionsSyntax    < CSDError; status_code(100); end
      class NoInstanceMethod < CSDError; status_code(101); end
    end
  
  end
end