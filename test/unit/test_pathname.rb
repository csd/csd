require 'helper'

class TestPathname < Test::Unit::TestCase
  
  context "A normal Pathname object" do
  
    should "be enquotable" do
      assert_equal '"/"', Pathname.new('/').enquote
    end
  
  end

end
