require 'optparse'
require 'optparse/time'
require 'ostruct'

module CSD
  class Options

    #
    # Returns a structure describing the options.
    #
    def self.parse
      # Default options
      options        = OpenStruct.new
      options.temp   = false
      options.silent = false
      options.dry    = false
      
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
        
        opts.on("-p", "--path [PATH]",
                "Defines the working directory manually.",
                "(This will override the --temp option)") do |value|
          options.path = value
        end
        
        opts.on("-s", "--silent","Don't show any output") do |value|
          options.silent = value
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts "CSD Gem Version: #{CSD::Init::GEM_VERSION}"
          exit
        end
      end.parse!
      options
    end

  end
end
