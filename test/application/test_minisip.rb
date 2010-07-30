require 'helper'
require 'csd/application/minisip'

class TestMinisip < Test::Unit::TestCase
  
  include CSD
  
  context "The MiniSIP instance" do
    
    setup do
      ARGV.clear
      Options.clear
      ARGV.push(@name)
      Applications.current!
      @app = Application::Minisip::Base.new
    end
    
    should "respond to a valid action" do
      assert @app.respond_to?(:compile)
    end
  
  end # context "The MiniSIP instance"
  
end
