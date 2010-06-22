require 'helper'

class TestPathname < Test::Unit::TestCase
  
  context "A normal Pathname object" do
  
    should "be enquotable" do
      assert_equal '"/"', Pathname.new('/').enquote
    end
    
    should "know if its the current pwd or not (regardless of the requested directory actually existing)" do
      Dir.chdir('/tmp')
      assert Pathname.new('/tmp').current_path?
      assert !Pathname.new('/i/do/not/exist').current_path?
    end
  
  end

end
