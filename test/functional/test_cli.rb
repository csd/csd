require 'helper'

class TestApplications < Test::Unit::TestCase
  
  include CSD
  
  context "The CLI instance" do
  
    setup do
      Options.clear
      Options.testmode = true
      Options.silent = false
      assert_instance_of UserInterface::CLI, CSD.ui
    end
    
    should "be able to indicate activity by printing periods" do
      out, err = capture do
        UI.indicate_activity
        UI.indicate_activity
        UI.indicate_activity
      end
      assert_equal '...', out
      assert_equal '', err
    end
  
    should "represent a separator by a new line" do
      out, err = capture do
        UI.separator
        UI.separator
        UI.separator
      end
      assert_equal "\n\n\n", out
      assert_equal '', err
    end

    should "log debugging messages in debug mode" do
      Options.debug = true
      out, err = capture do
        UI.debug "debugging"
      end
      assert_match /debugging/, out
      assert_equal '', err
    end
    
    should "NOT log debugging messages UNLESS debug mode" do
      Options.debug = false
      out, err = capture do
        UI.debug "debugging"
      end
      assert_equal '', out
      assert_equal '', err
    end
    
    should "log info messages" do
      out, err = capture do
        UI.info "informing"
      end
      assert_match /informing/, out
      assert_equal '', err
    end
    
    should "log warning messages" do
      out, err = capture do
        UI.warn "waaarning"
      end
      assert_match /waaarning/, out
      assert_equal '', err
    end
    
    should "log error messages to STDOUT" do
      out, err = capture do
        UI.error "erroring"
      end
      assert_equal '', out
      assert_match /erroring/, err
    end
   
  end # context "An CLI instance"

end
