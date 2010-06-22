require 'optparse'
require 'optparse/time'
require 'ostruct'

module Csd
  class Options

    #
    # Returns a structure describing the options.
    #
    def self.parse
      # Default options
      options              = OpenStruct.new
      options.temp         = false
      options.silent       = false
      options.dry          = false
      options.bootstrap    = true
      options.configure    = true
      options.make         = true
      options.make_install = true
      options.owner        = nil
      options.apt_get      = true
      options.yes          = false

      # Parse the command line options
      OptionParser.new do |opts|
        opts.banner = "Usage: csd [action] [application] [options]"
        opts.separator ""
        opts.separator "Actions:"
        opts.separator "    install"
        opts.separator ""
        opts.separator "Applications:"
        opts.separator "    minisip"
        opts.separator ""
        opts.separator "Options:"
        
        opts.on("-t", "--temp",
                "Use a subdirectory in the system's temporary directory",
                "to download files and not the current directory") do |value|
          options.temp = value
        end
        
        opts.on("-d", "--dry","Don't execute any commands, just show them") do |value|
          options.dry = value
        end

        opts.on("-y", "--yes","Answering all questions with 'yes'") do |value|
          options.yes = value
        end
        
        opts.on("-na", "--no-apt-get","Don't run any apt-get commands") do |value|
          options.apt_get = value
        end
        
        opts.on("-nb", "--no-bootstrap","Don't run any bootstrap commands") do |value|
          options.bootstrap = value
        end
        
        opts.on("-nc", "--no-configure","Don't run any configure commands") do |value|
          options.configure = value
        end
        
        opts.on("-nm", "--no-make","Don't run any make commands") do |value|
          options.make = value
        end
        
        opts.on("-nmi", "--no-make-install","Don't run any make install commands") do |value|
          options.make_install = value
        end
        
        opts.on("--only libmcrypto,libmnetuli,etc.", Array, "Include only these libraries") do |list|
          options.only = list
        end

        opts.on("-o", "--owner [OWNER]","Specify OWNER:GROUP for this operation") do |value|
          options.owner = value
        end
        
        opts.on("-p", "--path [PATH]",
                "Defines the working directory manually.",
                "(This will override the --temp option)") do |value|
          options.path = value
        end
        
        
        opts.on("-d", "--debug","Show debugging information") do |value|
          options.quiet = value
        end
        
        opts.on("--verbose","Show elaborate output") do |value|
          options.quiet = value
        end
                
        opts.on("-s", "--silent","Don't show any output") do |value|
          options.silent = value
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts "CSD Gem Version: #{File.read(File.join(PathContainer.new.gem_root, 'VERSION'))}"
          exit
        end
      end
      
      #.parse!
      
      if options.owner
        chmod = options.owner.split(':')
        options.owner = chmod.first
        options.group = chmod.last
      end
      
      options
    end

  end
end
