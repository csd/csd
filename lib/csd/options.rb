require 'optparse'
require 'optparse/time'
require 'ostruct'
#require 'active_support/core_ext/string'

module CSD
  # A class that handles the command line option parsing and manipulation
  #
  class Options < GlobalOpenStruct

    # Parse all options that the user gave as command parameter. Note that this function strips the options
    # from ARGV and leaves only non-option parameters (i.e. actions/applications; strings without -- and -).
    #
    def self.parse!
      OptionParser.new do |opts|
        opts.banner = "Usage: ".bold + "csd ACTION APPLICATION [SCOPE] [OPTIONS]".magenta.bold
        
        # TODO: Check for action so that we can guarantee that ARGV.second is the desired application name
        if !ARGV.first.starts_with?('-') #and Applications.current.name = Applications.find(ARGV.second).name
          self.action = ARGV.first.downcase
          begin
            opts.headline "OPTIONS (#{Applications.current} specific)".green.bold
            CSD.ui.debug "No options were loaded from #{Applications.current}"# if Applications.current.option_parser.size.blank?
            eval Applications.current.option_parser
          rescue Exception => e
            puts "The individual options of #{Applications.current.inspect} could not be parsed."
            puts
            exit 1
          end
        else
          opts.headline "ACTIONS".green.bold
          opts.list_item 'show',           'Shows information about an application'
          opts.list_item 'download',       'Downloads an application (e.g. source code, documentation,...)'
          opts.list_item 'install',        'Installs an application via a pre-compiled package'
          opts.list_item '  run',        'Executes an installed application'
          opts.list_item '  update',     'Updates an installed application'
          opts.list_item '  remove',     'Removes an installed application'
          opts.list_item 'build',          'Downloads and compiles an application'
          opts.list_item '  package',     'Packages a compiled application'
          opts.list_item '     publish', 'Submits a compiled package to the CSD package repository'
          opts.headline "APPLICATIONS".green.bold
          Applications.all { |app| opts.list_item(app.name, app.description) }
        end
        
        opts.headline "SCOPES".green.bold
        opts.list_item "(Depends on the action and the application. Type `" + "csd show APPLICATION".magenta.bold + "´ for more info)"
        
        opts.headline "OPTIONS".green.bold
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
        opts.on_tail("-h", "--help", "Show detailed help (including the given ACTION and APPLICATION)") do
          print opts.help
          puts
          exit
        end
        opts.on_tail("-v", "--version", "Show version") do
          print "CSD Gem Version: #{opts.version}".blue
          exit
        end
      end.parse!

      self.action      = ARGV.first
      self.application = ARGV.second
      self.scope       = ARGV.third
    end

  end
end
