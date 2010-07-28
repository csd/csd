# -*- encoding: UTF-8 -*-
require 'csd/user_interface/base'

module CSD
  module UserInterface
    class CLI < Base
    
      include Gem::UserInteraction
      
      def separator
        $stdout.puts
      end
      
      def indicate_activity
        $stdout.putc '.'
        $stdout.flush
      end
      
      def debug(message)
        $stdout.puts "DEBUG: #{message}".magenta if Options.debug
      end
      
      def info(message)
        $stdout.puts message
      end
      
      def warn(message)
        $stdout.puts 'NOTE: '.red + message.red
      end
      
      def error(message)
        $stderr.puts('ERROR: '.red.blink + message.red)
      end

    end
  end
end