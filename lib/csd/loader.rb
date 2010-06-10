require 'optparse'

module CSD
  
  class Loader
    
    def initialize(args)
        options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: example.rb [options]"

          opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
            options[:verbose] = v
          end
        end.parse!
        p options
        p ARGV
    end
    
    
  end
  
end