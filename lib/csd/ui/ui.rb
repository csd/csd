require 'active_support/json'

module CSD
  class UI
    
    include Gem::UserInteraction
    
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

  end
end