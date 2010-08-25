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
        assert !Options.scope
      end
    
      should "find a lonely help parameter" do
        ARGV.push 'help'
        Options.parse_literals
        assert Options.help
        assert !Options.application
        assert !Options.action
        assert !Options.scope
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
          assert !Options.scope
        end
        
        should "find an action along with the application" do
          ARGV.push 'myaction'
          ARGV.push @app
          Options.parse_literals
          assert !Options.help
          assert_equal 'myaction', Options.action
          assert_equal @app, Options.application
          assert !Options.scope
        end
        
        should "find an action along with the application and a scope" do
          ARGV.push 'myaction'
          ARGV.push @app
          ARGV.push 'myscope'
          Options.parse_literals
          assert !Options.help
          assert_equal 'myaction', Options.action
          assert_equal @app, Options.application
          assert_equal 'myscope', Options.scope
        end
        
        should "find an action along with the application in help mode" do
          ARGV.push 'help'
          ARGV.push 'myaction'
          ARGV.push @app
          Options.parse_literals
          assert Options.help
          assert_equal 'myaction', Options.action
          assert_equal @app, Options.application
          assert !Options.scope
        end
        
        should "find an action along with the application and a scope in help mode" do
          ARGV.push 'help'
          ARGV.push 'myaction'
          ARGV.push @app
          ARGV.push 'myscope'
          Options.parse_literals
          assert Options.help
          assert_equal 'myaction', Options.action
          assert_equal @app, Options.application
          assert_equal 'myscope', Options.scope
        end
        
        should "understand whether an action is invalid" do
          ARGV.push 'help'
          ARGV.push 'invalid_action'
          ARGV.push @app
          Options.parse_literals
          Options.actions_names = ['valid_action']
          assert !Options.valid_action?
          assert !Options.valid_scope?
          assert !Options.scope
        end

        should "understand whether an action is invalid when a scope is given" do
          ARGV.push 'help'
          ARGV.push 'invalid_action'
          ARGV.push @app
          ARGV.push 'myscope'
          Options.parse_literals
          Options.actions_names = ['valid_action']
          assert !Options.valid_action?
          assert !Options.valid_scope?
          assert_equal 'myscope', Options.scope
        end
        
        should "understand whether an action is valid when a scope is given" do
          ARGV.push 'help'
          ARGV.push 'valid_action'
          ARGV.push @app
          ARGV.push 'myscope'
          Options.parse_literals
          Options.actions_names = ['valid_action']
          assert Options.valid_action?
          assert !Options.valid_scope?
          assert_equal 'myscope', Options.scope
        end
        
        should "understand whether a scope is invalid when a valid action is given" do
          ARGV.push 'help'
          ARGV.push 'valid_action'
          ARGV.push @app
          ARGV.push 'invalid_scope'
          Options.parse_literals
          Options.actions_names = ['valid_action']
          Options.scopes_names = ['valid_scope']
          assert Options.valid_action?
          assert !Options.valid_scope?
          assert_equal 'invalid_scope', Options.scope
        end
        
        should "understand whether a scope is valid when a valid action is given" do
          ARGV.push 'help'
          ARGV.push 'valid_action'
          ARGV.push @app
          ARGV.push 'valid_scope'
          Options.parse_literals
          Options.actions_names = ['valid_action']
          Options.scopes_names = ['valid_scope']
          assert Options.valid_action?
          assert Options.valid_scope?
          assert_equal 'valid_scope', Options.scope
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
