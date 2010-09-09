require 'helper'

class TestString < Test::Unit::TestCase
  
  context "A normal String object" do
  
    should "be enquotable" do
      assert_equal '"wow it works"', 'wow it works'.enquote
    end
    
    should "be one-way SHA hashable" do
      assert_equal '9f4921b51c2e573cead9af22c0e0d1a14ad7b643', 'csd'.hashed
    end
    
  end

end
