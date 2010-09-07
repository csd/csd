# -*- encoding: UTF-8 -*-

module CSD
  # User Interaction is performed within this namespace.
  #
  module UserInterface
    # This is the parent class of all user interfaces.
    #
    class Base
      
      def separator
      end
      
      def indicate_activity
      end
      
      def ask_yes_no(question, default=nil)
      end
      
      def continue?
        ask_yes_no 'Continue?', true
      end
      
      def debug(message)
      end
      
      def info(message)
      end
      
      def warn(message)
      end
      
      def error(message)
      end
      
    end
  end
end