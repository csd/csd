require 'helper'

class TestString < Test::Unit::TestCase
  
  context "A normal String object" do
  
    should "be enquotable" do
      assert_equal '"wow it works"', 'wow it works'.enquote
    end
  
  end

end
