require 'helper'

class TestApplications < Test::Unit::TestCase

  include CSD

  context "The CSD class" do
    
    setup do
      Options.clear
    end
    
    should "by default choose the CLI as user interface" do
      assert_instance_of UserInterface::CLI, CSD.ui
    end

    should "perform no caching of the UI class in testmode" do
      Options.testmode = true
      Options.silent = false
      assert_instance_of UserInterface::CLI, CSD.ui
      Options.silent = true
      assert_instance_of UserInterface::Silent, CSD.ui
    end
   
  end # context "The CSD class"

end
