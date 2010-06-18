require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'tmpdir'
require 'redgreen'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'csd'

class Test::Unit::TestCase

  def ensure_mkdir(target)
    target = Pathname.new(target) unless target.is_a?(Pathname)
    target.mkpath
    assert target.directory?
    target
  end

end