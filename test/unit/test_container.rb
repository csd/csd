require 'helper'

class TestContainer < Test::Unit::TestCase
  
  include CSD
  
  context "The container" do
    
    setup do
      Options.clear
    end
  
    should "have options" do
      assert_equal Options.marshal_dump, CSD.options.marshal_dump
    end
    
    should "have options that can be cleared" do
      assert_equal Options.marshal_dump, CSD.options.marshal_dump
      Options.must_be_cleared = true
      assert Options.must_be_cleared
      assert_equal Options.marshal_dump, CSD.options.marshal_dump
      Options.clear
      assert !Options.must_be_cleared
      assert_equal Options.marshal_dump, CSD.options.marshal_dump
    end
    
  end

end
