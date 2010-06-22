require File.join(File.dirname(__FILE__), '..', 'commands')
require 'rbconfig'

module Csd
  module Application
    
    # This is the class root parent of all Applications
    #
    class Base
      
      include Commands
      include Gem::UserInteraction
      
      attr_reader :gem_version, :options
      attr_reader :after_build, :before_build # Dummies to be overwritten by methods
      attr_accessor :path
      
      def initialize(options={})
        @gem_version = options[:gem_version]
        @options     = options[:options]
        @path        = options[:path]
        self
      end
      
      def introduction
        say "CSD Version: #{gem_version}".blue
      end
      

      
    end
  end
end
