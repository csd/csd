require 'optparse'
require 'optparse/time'
require 'ostruct'

module Csd
  # A class that handles the command line option parsing and manipulation
  #
  class Options

    # Parse all options that the user gave as command parameter. Note that this function strips the options
    # from ARGV and leaves only non-option parameters (i.e. actions/applications; strings without -- and -).
    #
    # ==== Returns
    #
    # An OpenStruct object describing the options.
    #
    def self.parse
      # Default options
      options              = OpenStruct.new
      options.yes          = false

      # Parse the command line options
      OptionParser.new do |opts|
        opts.separator "Usage: csd ACTION APPLICATION [SCOPE] [OPTIONS]".blue.bold

        opts.headline "ACTIONS".green.bold
        opts.subheadline "For users".yellow
        opts.list_item 'install',       'Installs an application via a pre-compiled package'
        opts.list_item '  |-run',           'Executes an installed application'
        opts.list_item '  |-update',        'Updates an installed application (not available for all)'
        opts.list_item '  \-remove',        'Removes an installed application (not available for all)'
        opts.list_item 'show',          'Shows information about an application'
        opts.subheadline "For developers".yellow
        opts.list_item 'download',      'Downloads an application'
        opts.list_item 'build',         'Downloads and compiles an application'
        opts.list_item '  \-package',    'Packages a compiled application (Developers only)'
        opts.list_item '     \-publish', 'Submits a compiled package to the CSD package repository'
        
        opts.headline "APPLICATIONS".green.bold
        Applications.all { |app| opts.list_item(app.dir_name, app.short_description)  }
        
        opts.headline "SCOPES".green.bold
        opts.separator "(Depends on the action and the application. Type `csd ACTION APPLICATION --help´ for more info)"
        
        opts.headline "OPTIONS".green.bold
        
        opts.subheadline "System interaction".yellow
        options.yes = false
        opts.on("-y", "--yes", "Answer all questions with `yes´ (batch mode)") do |value|
          options.yes = value
        end
        options.dry = false
        opts.on("-p", "--dry","Don't actually execute any commands (preview mode)") do |value|
          options.dry = value
        end
        options.reveal = false
        opts.on("-r", "--reveal","List all commands that normally would be executed in this operation") do |value|
          options.reveal = value
        end
        
        opts.subheadline "Information output".yellow
        options.verbose = false
        opts.on("-e", "--verbose","Show elaborate output") do |value|
          options.verbose = value
        end
        options.debug = false
        opts.on("-d", "--debug","Show elaborate output and debugging information") do |value|
          options.debug = value
        end
        options.silent = false
        opts.on("-s", "--silent","Don't show any output") do |value|
          options.silent = value
        end
        
        opts.subheadline "Basics".yellow
        opts.on_tail("-h", "--help", "Show detailed help regarding the given parameters") do
          print opts.summarize
          puts
          exit
        end
        opts.on_tail("-v", "--version", "Show version") do
          print "CSD Gem Version: #{opts.version}".blue
          exit
        end
      end.parse!
      
      options
    end

  end
end
