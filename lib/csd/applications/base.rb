require File.join(File.dirname(__FILE__), '..', 'commands')
require 'rbconfig'

module Csd
  module Application
    
    # This is the class root parent of all Applications
    #
    class Base
      
      include Commands
      include Gem::UserInteraction
      
      attr_reader :options
      attr_reader :after_build, :before_build # Dummies to be overwritten by methods
      attr_accessor :path
      
      def initialize(options={})
        @options     = options[:options]
        @path        = options[:path]
        self
      end
      
      def introduction
        say "This is the Application Base Introduction".blue
      end
      
    end
  end
end
