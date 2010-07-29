# -*- encoding: UTF-8 -*-

module CSD
  class << self
    
    # This method holds the user interface instance.
    #
    def ui
      # In testmode we don't want to perform caching
      return choose_ui if Options.testmode
      # Otherwise we choose and cache the UI here
      @@ui ||= choose_ui
    end
    
    # This method chooses an user interface instance according to the Options and returns a new instance of it.
    #
    def choose_ui
      if Options.silent
        UserInterface::Silent.new
      else
        UserInterface::CLI.new
      end
    end
  
    # This method chooses and holds the command execution instance.
    #
    def cmd
      @@cmd ||= Commands.new
    end
  
    # This holds the container for paths.
    #
    def path
      @@path ||= PathContainer.new
    end
  
    # This holds the container for argument options.
    #
    def options
      @@options ||= OptionsParser.new
    end
  end

  # A wrapper for the UI class to be able to run all methods as class methods.
  #
  class UI
    def self.method_missing(meth, *args, &block)
      ::CSD.ui.send(meth, *args, &block)
    end
  end

  # A wrapper for the Commands class to be able to run all methods as class methods.
  #
  class Cmd
    def self.method_missing(meth, *args, &block)
      ::CSD.cmd.send(meth, *args, &block)
    end
  end

  # A wrapper for the Path class to be able to run all methods as class methods.
  #
  class Path
    def self.method_missing(meth, *args, &block)
      ::CSD.path.send(meth, *args, &block)
    end
  end

  # A wrapper for the Options class to be able to run all methods as class methods.
  #
  class Options
    # Because the Options class will respond to clear, we must pass it on explicitly to the OptionsParser instance residing in CSD.options
    #
    def self.clear
      ::CSD.options.clear
    end
    def self.method_missing(meth, *args, &block)
      ::CSD.options.send(meth, *args, &block)
    end
  end
end