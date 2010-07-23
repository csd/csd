# -*- encoding: UTF-8 -*-
require 'csd/user_interface/base'

module CSD
  module UserInterface
    class CLI < Base
    
      include Gem::UserInteraction
    
      def separator
        say
      end
      
      def indicate_activity
        $stdout.putc '.'
        $stdout.flush
      end
    
      def debug(message)
        say "DEBUG: #{message}".magenta if Options.debug and !Options.silent
      end
    
      def info(message)
        say message if !Options.silent
      end
    
      def warn(message)
        say 'NOTE: '.red + message.red if !Options.silent
      end

      def error(message)
        say('ERROR: '.red.blink + message.red) if !Options.silent
      end
    
      def die(message)
        say('ERROR: '.red.blink + message.red) if !Options.silent
        raise Error::UI::Die
      end

    end
  end
end