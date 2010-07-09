require 'active_support/json'

module CSD
  class UI
    
    include Gem::UserInteraction
    
    # These are all possible user interactions provided by the UI
    #
    INTERACTIONS = %w{ separator debug info warn error ask }
    
    def separator
      say
    end
    
    def debug(message)
      say "DEBUG: #{message}".magenta if Options.debug and !Options.silent
    end
    
    def info(message)
      say message if !Options.silent
    end
    
    def warn(message)
      say message.red if !Options.silent
    end

    def error(message)
      say message.red.blink if !Options.silent
    end
    
    def die(message)
      say message.red.blink if !Options.silent
      exit
    end
    
    protected
    
    # This is just a convenience wrapper so that +UI.myinteraction+ will map to +CSD.ui.myinteraction+
    #
    def self.method_missing(meth, *args, &block)
      INTERACTIONS.include?(meth.to_s) ? CSD.ui.send(meth.to_sym, *args, &block) : super
    end

  end
end