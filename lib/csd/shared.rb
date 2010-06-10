require 'term/ansicolor'
require 'rbconfig'

module CSD
  module Shared
    
    include Term::ANSIColor
    
    def run_command(cmd)
      log "Running command: #{cmd}".green.bold
      ret = ''
      IO.popen(cmd) do |stdout|
        stdout.each do |line|
          log line
          ret << line
        end
      end
      ret
    end

    def log(msg)
      puts msg if @options[:verbose]
    end
      
  end
end