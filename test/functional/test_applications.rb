require 'helper'
require 'ostruct'

class TestApplications < Test::Unit::TestCase
  
  include CSD
  
  context "As a file directory system function" do

    context "find" do
      
      should "dummy" do
        assert true
      end
      
    end

    context "all" do

      #should "return all apropriete Application objects as an array" do
      #  dirs = Dir.directories(Path.applications)
      #  apps = Applications.all
      #  assert_equal dirs.size, apps.size
      #  Applications.all do |app|
      #    assert_includes directories, 'app'
      #  end
      #  
      #end
      
    end # context "directories"
  
  end # context "As a Dir function"

end
