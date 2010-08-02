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
      
      # Be careful, this function writes to +STDOUT+ and not to <tt>$stdout</tt>. In other words,
      # the output cannot be hidden from the end-user, and thus, for example, not be properly
      # tested in the test suite. ask_yes_no is provided by Gem::UserInteraction.
      #
      def continue?
        ask_yes_no("Continue?".red.bold, true)
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