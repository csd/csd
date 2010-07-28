require 'rubygems'
require 'test/unit'
require 'tmpdir'
require 'shoulda'
require 'redgreen'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'csd'
require 'csd/vendor/zentest/zentest_assertions'

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