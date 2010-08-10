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
    
    should "give a nice debugging output" do
      @os.myoption = 'I am cool'
      @os.helptext = 'I am helpful'
      assert_match /helptext/, @os.inspect
      assert_no_match /helptext=nil/, @os.inspect
      assert_match /helptext=nil/, @os.inspect_for_debug
    end
    
  end

end
