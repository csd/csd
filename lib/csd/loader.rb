require File.join(File.dirname(__FILE__), 'installer')
require 'optparse'

module CSD
  class Loader
    
    def initialize
      @options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: csd [options]"
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          @options[:verbose] = v
        end
      end.parse!
      
      case ARGV.first
        when 'install'
          installer = Installer.new
        else
          puts 'Run csd -h to get help.'
      end
      self
    end
    
    
    
    
  end
end