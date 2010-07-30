require 'helper'
require 'csd/application/minisip'

class TestMinisipCore < Test::Unit::TestCase
  
  include CSD
  include Application::Minisip::Component
  
  context "The Minisip Core component" do
  
    setup do
      ARGV.clear
      Options.clear
      ARGV.push(@name)
      Applications.current!
      @app = Application::Minisip::Base.new
    end
    
    should "know how to identify and sort a subset of internal MiniSIP libraries with --only" do
      Options.only = nil
      assert_equal Core::LIBRARIES, Core.libraries
      Options.only = %w{ libmcrypto }
      assert_equal %w{ libmcrypto }, Core.libraries
      Options.only = %w{ does-not-exist }
      assert Core.libraries == []
      Options.only = Core::LIBRARIES
      assert_equal Core::LIBRARIES, Core.libraries
      Options.only = %w{ minisip libmutil }
      assert_equal %w{ libmutil minisip }, Core.libraries
    end
    
  end # context "The Minisip Core component"
  
end
