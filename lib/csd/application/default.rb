# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'
require 'yaml'

module CSD
  # This namespace holds all individual application Modules.
  #
  module Application
  
    # This is a module which contains all methods that each Application must implement. It provides
    # the basic functionality so that it can be simply included by a real Application module to get
    # started. The only thing that (in that case) really needs to be implemented is the +instance+
    # method which chooses and holds the actual Application Module instance which will perform the
    # task. All other functions in this module just require an +about.yml+ file to be placed in the
    # specific application sub-directory.
    #
    module Default
      
      # This method must be overwritten by the actual application module. It holds the application instance
      # which was chosen for this operating system.
      #
      def instance
        raise Error::Application::NoInstanceMethod, "The application module must define an method called `instance´."
      end
      
      # This method returns the Name of the application formatted as a command-line argument. By default
      # it returns the name of the own class without capital letters. E.g. the class +MyClass+ would turn
      # into +my_class+. It can be overwritten by the implementation of the actual application if another
      # name is desired, or if the name needs to change in the future for some reason.
      #
      def name
        self.to_s.demodulize.underscorize
      end
      
      # This method returns a short description of the application. By default it just reads the description
      # provided in the +about.yml+ file. It can be overwritten if the +about.yml+ file is not used for some reason.
      #
      def description
        about.description
      end
      
      # In order to present the name of this application to humans, neither the class name, nor the name
      # as it appears in a command-line argument should be used. In other words, it should not be +Minisip+
      # or +minisip+, but +MiniSIP+. This method returns that string and it is manually defined in the
      # +about.yml+ file.
      #
      def human
        about.human
      end
      
      # This method returns a hash containing all valid actions (i.e. tasks) for this application. Note that
      # the structure of this hash must be in a particular way. In the first level of the hash, a differentiation
      # is made between actions intended for public use, such as "install" and for AI-developer use, such as
      # "compile" or "package". For example:
      #
      #  {'public' => [...], 'developer' => [...]}
      #
      # Each of these two keys holds an +Array+ with the actions. Each action is defined as a hash with the key
      # as the action name and the value as the action description. One action looks like this for example:
      #
      #  [{'install' => 'Downloads and installs the cooles application of all'}]
      #
      # Several actions look like this, respectively:
      #
      #   [ {'install' => 'Downloads and installs the cooles application of all'},
      #     {'update'  => 'Updates this cool application fully automatically'}      ]
      #
      # The reason for choosing an Array and not a Hash to hold the actions is, because when they are presented
      # to the end-user, the order of listing them up should be definable. It is not alphabetically, but sorted
      # manually. A fully valid return value might look like this:
      #
      #  { 'public'    => [ {'install' => 'Downloads and installs this application'  }
      #                     {'remove'  => 'Removes this cool application immediately'} ],
      #    'developer' => [ {'package' => 'Creates a debian-package for this application'} ]
      #  }
      #
      def actions
        about.actions
      end
      
      # Some applications might react not only to tasks (such as +install+ or +compile+), but also to a more
      # fine-grained scope. Typically this is a sub-component of an application. For example, MiniSIP has the
      # sub-components "FFmpeg", "HDVIPER", "Plugins", etc. If an AI-developer wants to test only a particular
      # part of the whole installation routine, he can instruct the AI to only perform the tasks needed to
      # install that sub-component. This will save a lot of time in testing the functionality. In general,
      # scopes are optional, but they may be defined here.
      #
      # The scopes are specific for each action. It might be that the "install" action of minisip, has scopes
      # a, b, and c, whereas the "compile" action has maybe no scope at all. Similarly to the +actions+ method,
      # this method defines scopes in a hash, where each key represents one action and the value holds an +Array+
      # of all available scopes.
      #
      def scopes(action)
        (about.scopes.is_a?(Hash) and about.scopes.key?(action)) ? about.scopes[action] : []
      end
      
      # This method will look for application and task specific optionsfiles of the current application module.
      # It returns the Ruby code in a +String+ to be eval'd by the OptionsParser.
      # If there are no files in myapplication/options, an empty +String+ is returned instead.
      #
      def options(action='')
        result = []
        ["#{action}.rb", "common.rb"].each do |filename|
          file = File.join(Path.applications, name, 'options', filename)
          result << File.read(file) if File.file?(file)
        end
        default_options(action) + result.join("\n")
      end
      
      # Comes in handy for the test suite
      #
      def default_options(action='')
        result = []
        ["common_defaults.rb", "#{action}_defaults.rb"].each do |filename|
          file = File.join(Path.applications, name, 'options', filename)
          result << File.read(file) if File.file?(file)
        end
        result.join("\n")
      end
    
      protected
    
      def about
        about_file = File.join(Path.applications, name, 'about.yml')
        OpenStruct.new YAML.load_file(about_file)
      end
    
    end
  end
end



