require 'helper'
require 'csd/application/minisip'

class TestDir < Test::Unit::TestCase
  
  include CSD
  
  context "The Minisip application" do
  
    setup do
      @app = Application::Minisip::Base.new
    end

    teardown do
    end
    
    should "respond to valid actions" do
      assert @app.respond_to?(:compile)
    end
    
    context "when downloading source code" do
  
      should "dummy" do
        assert true
      end
      
    end # context "when downloading source code"
  
  end # context "The Minisip application"
  
end
