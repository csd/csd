require File.join(File.dirname(__FILE__), 'shared')
require File.join(File.dirname(__FILE__), 'installer')
require File.join(File.dirname(__FILE__), '..', 'apps', 'minisip')

require 'optparse'
require 'term/ansicolor'

module CSD
  class Loader
    
    include Gem::UserInteraction
    
    def initialize
      @options = {}
      @actions = ARGV
      OptionParser.new do |opts|
        opts.banner = "Usage: csd [options]"
        opts.on("-s", "--silent", "Don't run verbosely") do |v|
          @options[:verbose] = !v
        end
      end.parse!
      
      introduction
      
      case @actions.shift
        when 'install'
          Installer.new :options => @options, :actions => @actions
        else
          puts "Unknown action, try 'csd install'"
      end
      self
    end
    
    def introduction
      puts
      puts "The current working directory is:"
      puts Dir.pwd
      puts
      exit unless ask_yes_no("Continue?", true)
    end
    
  end
end

class String
  include Term::ANSIColor
end