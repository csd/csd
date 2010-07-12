require 'helper'

class TestOptions < Test::Unit::TestCase
  
  include CSD
  
  context "When analyzing arguments" do
  
    setup do
      ARGV.clear
      assert ARGV.empty?
      Options.clear
    end
  
    context "and identifying just help/action/application, parse_literals" do
      
      teardown do
        assert ARGV.empty?
      end
    
      should "not set anything if there is nothing" do
        Options.parse_literals
        assert !Options.help
        assert !Options.application
        assert !Options.action
      end
    
      should "find a lonely help parameter" do
        ARGV.push 'help'
        Options.parse_literals
        assert Options.help
        assert !Options.application
        assert !Options.action
      end
        
      context "together with a valid application" do
    
        setup do
          @app = 'minisip'
          assert Applications.find(@app)
        end
    
        should "find the lonely application" do
          ARGV.push @app
          Options.parse_literals
          assert !Options.help
          assert_equal @app, Options.application
          assert !Options.action
        end
        
        should "find an action along with the application" do
          ARGV.push 'myaction'
          ARGV.push @app
          Options.parse_literals
          assert !Options.help
          assert_equal 'myaction', Options.action
          assert_equal @app, Options.application
        end
        
        should "find an action along with the application in help mode" do
          ARGV.push 'help'
          ARGV.push 'myaction'
          ARGV.push @app
          Options.parse_literals
          assert Options.help
          assert_equal 'myaction', Options.action
          assert_equal @app, Options.application
        end
        
        should "understand whether an action is invalid" do
          ARGV.push 'help'
          ARGV.push 'invalid_action'
          ARGV.push @app
          Options.parse_literals
          Options.actions = {'valid_action' => 'I am valid'}
          assert_includes 'valid_action', Options.actions
          assert !Options.valid_action?
        end
    
      end # context "together with a valid application"
    
    end # context "and identifying help/action/application, parse_literals"
  
    context "and identifying help/action/application together with scopes, parse_literals" do
      
      should "know when it is a lonely non-application literal parameter" do
        ARGV.push('myaction')
        Options.parse_literals
        assert !Options.help
        assert !Options.application
        assert !Options.action
      end
      
    end # context "and identifying help/action/application together with scopes, parse_literals"
  
  end # context "When analyzing the options"

end
