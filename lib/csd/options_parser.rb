# -*- encoding: UTF-8 -*-
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'csd/extensions'

module CSD
  # A class that handles the command line option parsing and manipulation
  #
  class OptionsParser < OpenStruct
    
    def parse!
      clear
      parse_literals
      define_actions_and_scopes
      parse_options
    end
    
    def valid_action?
      self.actions_names.include?(self.action)
    end
    
    def valid_scope?
      self.scopes_names.include?(self.scope)
    end
    
    def define_actions_and_scopes
      if Applications.current
        # Here we overwrite the default supported actions and scopes with the application specific ones
        UI.debug "#{self.class}#define_actions_and_scopes loads the actions of #{Applications.current} now"
        self.actions       = Applications.current.actions
        public_actions    = actions['public'] ? self.actions['public'].map { |pair| pair.keys.first } : []
        developer_actions = actions['developer'] ? self.actions['developer'].map { |pair| pair.keys.first } : []
        self.actions_names = public_actions + developer_actions
        #UI.debug "#{self.class}#define_actions_and_scopes identified the actions #{self.actions.inspect}"
        # At this point we know that the first argument is no option, but *some* action (may it be valid or not)
        UI.debug "#{self.class}#define_actions_and_scopes loads the scopes of #{Applications.current} now"
        self.scopes       = Applications.current.scopes(self.action)
        self.scopes_names = self.scopes.map { |pair| pair.keys.first }
        #UI.debug "#{self.class}#define_actions_and_scopes identified the scopes #{self.scopes.inspect}"
      end
    end
    
    def clear(additional_options='')
      # Resetting all attributes to nil (because e.g. an application instance might have modified or added some).
      super()
      # First we define all valid actions and scopes
      self.actions       = []
      self.actions_names = []
      self.scopes        = []
      self.scopes_names  = []
      # Then we define the default literals
      self.help        = false
      self.application = nil
      self.action      = nil
      # Now we define the default options
      self.yes       = false
      self.local     = false
      self.reveal    = false
      self.verbose   = false
      self.silent    = false
      self.developer = false
      # Shortcut to allow for debugging the options parser itself
      self.debug     = (ARGV.include?('--debug') or ARGV.include?('-d'))
      # For our test suite we might want to inject more options here
      eval additional_options
    end

    # Here we check for literals, i.e. "help", ACTION and APPLICATION.
    #
    def parse_literals
      # First let's see whether we are in help mode, i.e. whether the first argument is `help´.
      # If so, we would like to remove it from the ARGV list.
      if ARGV.first == 'help'
        self.help = true
        ARGV.shift
      end
      # The action and the application name are the other literals we're interested in at this point.
      # Note: If there is no application specified, there is pretty much nothing we can do for the user.
      if Applications.current and Applications.current.name == ARGV.first
        # The application name is the first argument (i.e. there is no action specified at all)
        # Let's store the application name and remove it from the argument line
        self.application = ARGV.shift
      elsif Applications.current and Applications.current.name == ARGV.second
        # The second argument is the application name. This means that the first argument must be the
        # action or happens to be some option. In case it's no option, lets take it as desired action.
        unless ARGV.first.starts_with?('-')
          self.action      = ARGV.shift
          self.application = ARGV.shift # Removing the application name from the argument list
        end
        # The only thing that is left is the scope, by now shifted from the third to the first location.
        # A literal must now be the desired scope
        if ARGV.first and not ARGV.first.starts_with?('-')
          self.scope = ARGV.shift
        end
      end
      UI.debug "#{self.class}#parse_literals identified the application `#{self.application}´, the action `#{self.action}´ and the scope `#{self.scope}´"
    end
    
    # Parse all options that the user gave as command parameter. Note that this function strips the options
    # from ARGV and leaves only literal (non-option) parameters (i.e. actions/applications/scopes; strings without -- and -).
    #
    def parse_options
      OptionParser.new do |opts|
        self.banner = Applications.current ? 'OPTIONS' : "Usage: ".bold + "#{CSD.executable} [help] [TASK] APPLICATION [OPTIONS]"
        opts.banner = self.banner.magenta.bold

        # Here we load application-specific options file.
        # TODO: There must be a better way for this in general than to eval the raw ruby code
        begin
          unless Applications.current.options(self.action).size == 0
            opts.headline "#{self.action.to_s.upcase} #{Applications.current.name.upcase} OPTIONS".green.bold
            eval Applications.current.options(self.action)
          else
            UI.debug "There were no options to be loaded from #{Applications.current}" 
          end
        rescue SyntaxError => e
          raise Error::Application::OptionsSyntax, "The individual options of #{Applications.current.inspect} could not be parsed (SyntaxError)."
        end if Applications.current
        
        # And here we load all general options
        options_prepend = Applications.current ? 'GENERAL ' : nil
        opts.headline "#{options_prepend}OPTIONS".green.bold
        opts.on("-y", "--yes", "Answer all questions with `yes´ (batch mode)") do |value|
          self.yes = value
        end
        #opts.on("-l", "--local","Assume that there is no uplink to the Internet") do |value|
        #  self.online = !value
        #end
        opts.on("-r", "--reveal","List all commands that normally would be executed in this operation (preview-mode)") do |value|
          self.reveal = value
        end
        opts.on("-e", "--verbose","Show more elaborate output") do |value|
          self.verbose = value
        end
        opts.on("-d", "--debug","Show more elaborate output and debugging information about the AI") do |value|
          self.debug = value
        end
        opts.on("-s", "--silent","Don't show any output") do |value|
          self.silent = value
        end
        opts.on_tail("-a", "--developer", "Show information only relevant to AI and MiniSIP developers") do |value|
          self.developer = value
        end
        opts.on_tail("-h", "--help", "Show detailed help (regarding the given ACTION and APPLICATION)") do |value|
          self.help = value
        end
        opts.on_tail("-v", "--version", "Show the version of this AI") do
          puts "CSD Gem Version: #{CSD::Version}".blue
          raise Error::Argument::VersionWasRequested
        end
        self.helptext = opts.help
      end.parse!
      rescue OptionParser::InvalidOption => e
        raise Error::Argument::InvalidOption, e.message.gsub('invalid option: ', 'This option argument seems to be incorrect: ')
    end

  end
end
