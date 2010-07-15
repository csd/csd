require 'helper'
require 'ostruct'

class TestApplications < Test::Unit::TestCase
  
  include CSD
  
  context "When analyzing arguments" do
  
    setup do
      ARGV.clear
      assert ARGV.empty?
      Options.clear
    end
    
    context "and considering a valid application" do

      setup do
        @app = 'minisip'
        assert Applications.find(@app)
      end
      
      context "the find function" do
    
        should "find an application in the first argument" do
          ARGV.push(@app)
          assert_equal @app, Applications.current!.name
        end
      
        should "find an application in the second argument" do
          ARGV.push('dummy')
          ARGV.push(@app)
          assert_equal @app, Applications.current!.name
        end
      
        should "find an application in the third argument" do
          ARGV.push('foo')
          ARGV.push('bar')
          ARGV.push(@app)
          assert_equal @app, Applications.current!.name
        end
      
        should "set nothing, if there is no valid app" do
          ARGV.push('foo')
          ARGV.push('bar')
          ARGV.push('bob')
          assert !Applications.current!
        end
        
      end # context "the find function"
      
      context "the application module" do
      
        should "know its name" do
          assert_equal @app, Applications.find(@app).name
        end
        
        should "respond to options with a string" do
          assert_kind_of(String, Applications.find(@app).options)
          assert_kind_of(String, Applications.find(@app).options('install'))
          assert_kind_of(String, Applications.find(@app).options('not_a_valid_action'))
        end
      
      end # context "the application module"
      
    end # context "and considering a valid application, find"
    
    context "find" do
      
      should "evaluate to +false+ for an empty application search term" do
        assert !Applications.find('')
      end
      
      should "evaluate to +false+ for an invalid application search term" do
        assert !Applications.find('i-for-sure-do-not-exist')
      end
      
    end
      
  end # context "When analyzing arguments"

    #context "all" do

      #should "return all apropriete Application objects as an array" do
      #  dirs = Dir.directories(Path.applications)
      #  apps = Applications.all
      #  assert_equal dirs.size, apps.size
      #  Applications.all do |app|
      #    assert_includes directories, 'app'
      #  end
      #  
      #end
      
    #end # context "directories"
  
  #end # context "As a Dir function"

end
