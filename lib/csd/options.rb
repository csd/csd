require 'optparse'
require 'optparse/time'
require 'ostruct'

module CSD
  # A class that handles the command line option parsing and manipulation
  #
  class Options < GlobalOpenStruct
    
    # Parse all options that the user gave as command parameter. Note that this function strips the options
    # from ARGV and leaves only literal (non-option) parameters (i.e. actions/applications/scopes; strings without -- and -).
    #
    def self.parse!
      # These option values hold names and descriptions for application-unspecific actions and scopes
      # They are intended to be overwritten by the specific application module
      self.actions      = YAML.load_file(File.join(Path.applications, 'actions.yml'))
      self.scopes       = [{"(Depends on the action and the application. Type `" + "#{CSD.executable} show APPLICATION".magenta.bold + "´ for more info)" => ''}]
      
      # Get the three optional literal arguments
      self.action      = ARGV.first if Applications.current # (There is no application without action)
      self.application = ARGV.second
      self.scope       = ARGV.third unless ARGV.third.to_s.starts_with?('-')
      
      # Now let's parse all command-line arguments. Here we only care for option arguments.
      OptionParser.new do |opts|
        opts.banner = "Usage: ".bold + "ai ACTION APPLICATION [SCOPE] [OPTIONS]".magenta.bold
        
        # This is self-explanatory :) There is separate method for this below
        get_application_specific_values
        
        # Whatever actions we have now, let's display them
        actions_prepend = Applications.current ? Applications.current.name.upcase + ' ' : nil
        opts.headline "#{actions_prepend}ACTIONS".green.bold
        self.actions[:public].each { |action| opts.list_item(action.keys.first, action.values.first) }
        
        # This is the point where we would show all applications, in case the application is not defined yet
        unless Applications.current
          opts.headline "APPLICATIONS".green.bold
          Applications.all { |app| opts.list_item(app.name, app.description) }
        end
        
        # If we have scopes for this action/application, let's display them
        if self.scopes
          scopes_headline = Applications.current ? "SCOPES for the #{self.action.to_s.upcase} action" : 'SCOPES'
          opts.headline scopes_headline.green.bold
          self.scopes.each { |scope| opts.list_item(scope.keys.first, scope.values.first) }
        end
        
        # Here we load application-specific options file.
        # TODO: There must be a better way for this in general than to eval the raw ruby code
        begin
          UI.debug "There were no options to be loaded from #{Applications.current}" if Applications.current.option_parser.size.blank?
          opts.headline "#{prepend}OPTIONS".green.bold
          eval Applications.current.option_parser
        rescue SyntaxError => e
          raise ApplicationOptionsSyntaxError, "The individual options of #{Applications.current.inspect} could not be parsed (SyntaxError)."
        end if Applications.current
        
        # And here we load all general options
        options_prepend = Applications.current ? 'GENERAL ' : nil
        opts.headline "#{options_prepend}OPTIONS".green.bold
        self.yes = false
        opts.on("-y", "--yes", "Answer all questions with `yes´ (batch mode)") do |value|
          self.yes = value
        end
        self.dry = false
        opts.on("-p", "--dry","Don't actually execute any commands (preview mode)") do |value|
          self.dry = value
        end
        self.reveal = false
        opts.on("-r", "--reveal","List all commands that normally would be executed in this operation") do |value|
          self.reveal = value
        end
        self.verbose = false
        opts.on("-e", "--verbose","Show more elaborate output") do |value|
          self.verbose = value
        end
        self.debug = false
        opts.on("-d", "--debug","Show more elaborate output and debugging information") do |value|
          self.debug = value
        end
        self.silent = false
        opts.on("-s", "--silent","Don't show any output") do |value|
          self.silent = value
        end
        opts.on_tail("-h", "--help", "Show detailed help (regarding the given ACTION and APPLICATION)") do
          print opts.help
          puts
          exit
        end
        opts.on_tail("-v", "--version", "Show version") do
          print "CSD Gem Version: #{opts.version}".blue
          exit
        end
      end.parse!

    end
    
    # Here we check for application-specific actions, options and scopes
    #
    def self.get_application_specific_values
      if Applications.current
        # Here we overwrite the default supported actions and scopes with the application specific ones
        self.actions = Applications.current.instance.actions
        # At this point we know that the first argument is no option, but *some* action (may it be valid or not)
        self.scopes  = Applications.current.instance.scopes(self.action)
      end
    end

  end
end
