require 'rbconfig'

module CSD
  module Application
    class Base
      
      include Gem::UserInteraction
      
      attr_reader :gem_version, :options
      attr_accessor :path
      
      def initialize(options={})
        @gem_version = options[:gem_version]
        @options     = options[:options]
        @path        = options[:path]
        self
      end
      
      def introduction
        say "CSD Gem Version: #{gem_version}"
        say
        say "The working directory is:"
        say path.root
      end
      
      def test_command(*args)
        say "Testing command for success: #{args.join(' ')}".cyan
        system(*args)
      end
      
      def run_command(cmd)
        log "Running command: #{cmd} in #{Dir.pwd}".magenta
        ret = ''
        unless options.dry
          IO.popen(cmd) do |stdout|
            stdout.each do |line|
              say line
              ret << line
            end
          end
        end
        ret
      end

      def log(msg="")
        say msg.yellow unless options.silent
      end
      
    end
  end
end
