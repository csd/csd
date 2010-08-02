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
    
    should "know whether it's debian or not" do
      assert !Gem::Platform.local.debian? if Gem::Platform.local.os == 'darwin'
      # TODO: This is not the best way to determine debian or red hat
      assert Gem::Platform.local.debian? if Gem::Platform.local.os == 'linux' and Cmd.run('which dpkg', :internal => true, :die_on_failure => false).success?
      assert !Gem::Platform.local.debian? if Gem::Platform.local.os == 'linux' and Cmd.run('which rpm', :internal => true, :die_on_failure => false).success?
    end
    
  end

end
