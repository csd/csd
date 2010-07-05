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
    def self.parse
      OptionParser.new do |opts|
        opts.banner = "Usage: ".bold + "csd ACTION APPLICATION [SCOPE] [OPTIONS]".magenta.bold
        
        
        # TODO: Check for action so that we can guarantee that ARGV.second is the desired application name
        if !ARGV.first.starts_with?('-') and Applications.current = Applications.find(ARGV.second)
          action = ARGV.first.downcase
          begin
            opts.headline "OPTIONS (#{Applications.current} specific)".green.bold
            eval Applications.current.options
          rescue Exception => e
            puts "The options file of #{Applications.current} could not be parsed."
            puts
            #super
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
        yes = false
        opts.on("-y", "--yes", "Answer all questions with `yes´ (batch mode)") do |value|
          yes = value
        end
        dry = false
        opts.on("-p", "--dry","Don't actually execute any commands (preview mode)") do |value|
          dry = value
        end
        reveal = false
        opts.on("-r", "--reveal","List all commands that normally would be executed in this operation") do |value|
          reveal = value
        end
        verbose = false
        opts.on("-e", "--verbose","Show more elaborate output") do |value|
          verbose = value
        end
        debug = false
        opts.on("-d", "--debug","Show more elaborate output and debugging information") do |value|
          debug = value
        end
        silent = false
        opts.on("-s", "--silent","Don't show any output") do |value|
          silent = value
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
      
      #puts parameters.inspect
      
     # parameters.parse!
      
      action      = ARGV.first
      application = ARGV.second
      scope       = ARGV.third
    end

  end
end
