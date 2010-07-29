require 'helper'
require 'ostruct'
require 'tmpdir'

module CSD
  module Application
    # This is our dummy application for testing
    #
    module Chess
      class << self
        include CSD::Application::Default
      end
    end
  end
end

class TestApplicationDefault < Test::Unit::TestCase
  
  include CSD
  
  context "the empty, default application module" do
    
    setup do
      @mod = Application::Chess
    end

    should "raise an error if the instance method was called" do
      assert_raise(Error::Application::NoInstanceMethod) { @mod.instance }
    end
    
  end
  
end
