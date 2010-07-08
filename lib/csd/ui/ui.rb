require 'active_support/json'

module CSD
  class UI
    
    include Gem::UserInteraction
    
    # These are all possible user interactions provided by the UI
    #
    INTERACTIONS = %w{ debug info warn error ask }
    
    def debug(message)
      say message
    end
    
    def info(message)
    end
    
    def warn(message)
    end

    def error(message)
      say message.red
      say
    end
    
    protected
    
    # This is just a convenience wrapper so that +UI.myinteraction+ will map to +CSD.ui.myinteraction+
    #
    def self.method_missing(meth, *args, &block)
      INTERACTIONS.include?(meth.to_s) ? CSD.ui.send(meth.to_sym, *args, &block) : super
    end

  end
end