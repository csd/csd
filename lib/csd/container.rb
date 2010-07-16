# -*- encoding: UTF-8 -*-

module CSD
  class << self
    # This method chooses and holds the user interface instance.
    #
    def ui
      @@ui ||= UserInterface::CLI.new
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
    def self.method_missing(meth, *args, &block)
      ::CSD.options.send(meth, *args, &block)
    end
  end
end