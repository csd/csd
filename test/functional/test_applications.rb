require 'helper'
require 'ostruct'
require 'tmpdir'

class TestApplications < Test::Unit::TestCase
  
  include CSD
  
  context "When analyzing arguments" do
  
    setup do
      ARGV.clear
      assert ARGV.empty?
      Options.clear
    end
    
    context "and considering an application module which can be loaded" do

      setup do
        @name = 'minisip'
        assert Applications.find(@name)
      end
      
      context "the find function" do
    
        should "find an application in the first argument" do
          ARGV.push(@name)
          assert_equal @name, Applications.current!.name
        end
      
        should "find an application in the second argument" do
          ARGV.push('dummy')
          ARGV.push(@name)
          assert_equal @name, Applications.current!.name
        end
      
        should "find an application in the third argument" do
          ARGV.push('foo')
          ARGV.push('bar')
          ARGV.push(@name)
          assert_equal @name, Applications.current!.name
        end
      
        should "set nothing, if there is no valid app" do
          ARGV.push('foo')
          ARGV.push('bar')
          ARGV.push('bob')
          assert !Applications.current!
        end
        
      end # context "the find function"
      
      context "the application module" do
        
        should "implement an instance method" do
          assert Applications.find(@name).respond_to?(:instance)
        end
      
        should "know its name" do
          assert_equal @name, Applications.find(@name).name
        end
        
        should "respond to options with a string" do
          assert_kind_of(String, Applications.find(@name).options)
          assert_kind_of(String, Applications.find(@name).options('install'))
          assert_kind_of(String, Applications.find(@name).options('not_a_valid_action'))
        end
        
      end # context "the application module"
      
    end # context "and considering a valid application, find"
    
    context "find" do
      
      should "do not evaluate to +true+ for an invalid application search term" do
        assert !Applications.find(nil)
        assert !Applications.find('')
        assert !Applications.find('i-for-sure-do-not-exist')
      end
      
    end
      
  end # context "When analyzing arguments"

end
