require 'helper'

class TestPlatform < Test::Unit::TestCase
  
  include CSD
  
  context "A Gem::Platform object for this machine" do
  
    setup do
      Options.clear
    end
  
    should "try to get kernel information if this is linux even in reveal mode" do
      if Gem::Platform.local.os == 'linux'
        Options.reveal = true
        assert Gem::Platform.local.kernel_release
        assert Gem::Platform.local.kernel_version
      end
    end
    
  end

end
