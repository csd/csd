require 'rubygems'
require 'test/unit'
require 'tmpdir'
require 'shoulda'
begin
  require 'redgreen'
rescue LoadError
  # Does not work on Ruby 1.9.1, but it is not really needed
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'csd'
require 'csd/vendor/zentest/zentest_assertions'

# This will cause tests to be executed which require Internet connection
ONLINE = system 'ping -c 1 www.google.com'
puts "WARNING:".red.blink + " Tests which require Internet connectivity will not be executed!".red unless ONLINE

class Test::Unit::TestCase
  
  # Even though the CSD library offers this function as an Kernel extension, we override it here.
  # It must be guaranteed it works during running the tests.
  #
  def superuser?
    Process.uid == 0
  end
  
  def ensure_mkdir(target)
    target = Pathname.new(target) unless target.is_a?(Pathname)
    target.mkpath
    assert target.directory?
    target
  end
  
  def assert_includes(elem, array, message = nil) 
    message = build_message message, ' is not found in .', elem, array 
    assert_block message do 
      array.include? elem 
    end 
  end
  
  def assert_excludes(elem, array, message = nil) 
    message = build_message message, ' is found in .', elem, array 
    assert_block message do 
      !array.include? elem 
    end 
  end
  
end