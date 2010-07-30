# -*- encoding: UTF-8 -*-
require 'csd/user_interface/base'

module CSD
  module UserInterface
    class Silent < Base
      
      def separator
      end
      
      def indicate_activity
      end
      
      def continue?
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