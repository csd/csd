require 'helper'
require 'csd/application/minisip'

class TestDir < Test::Unit::TestCase
  
  include CSD
  
  context "The Minisip application" do
  
    setup do
      Options.clear
      @app = Application::Minisip::Base.new
    end
    
    should "respond to a valid action" do
      assert @app.respond_to?(:compile)
    end
    
    should "know how to identify and sort a subset of internal MiniSIP libraries with --only" do
      Options.only = nil
      assert_equal Application::Minisip::Base::LIBRARIES, @app.libraries
      Options.only = %w{ libmcrypto }
      assert_equal %w{ libmcrypto }, @app.libraries
      Options.only = %w{ does-not-exist }
      assert @app.libraries == []
      Options.only = Application::Minisip::Base::LIBRARIES
      assert_equal Application::Minisip::Base::LIBRARIES, @app.libraries
      Options.only = %w{ minisip libmutil }
      assert_equal %w{ libmutil minisip }, @app.libraries
    end
    




    
    context "when downloading source code" do
    
      should "dummy" do
        assert true
      end
      
    end # context "when downloading source code"
  
  end # context "The Minisip application"
  
end
