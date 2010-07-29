require 'helper'
require 'ostruct'

class TestOpenStruct < Test::Unit::TestCase
  
  context "A normal OpenStruct object" do
    
    setup do
      @os = OpenStruct.new :bill => :gates, :steve => :jobs
    end
  
    should "be clearable" do
      assert_equal :gates, @os.bill
      assert_equal :jobs, @os.steve
      @os.clear
      assert_nil @os.bill
      assert_nil @os.steve
    end
    
  end

end
