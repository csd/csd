require 'helper'
require 'ostruct'
require 'tmpdir'

class TestApplicationBase < Test::Unit::TestCase
  
  include CSD
  
  context "An application instance" do
  
    setup do
      Options.clear
      assert @app = Applications.find('minisip').instance
    end
    
    should "use a temporary directory as working directory when the --temp options is given" do
      Options.temp = true
      @app.define_working_directory
      # We verify whether this is a tempory directory by comparing the first six characters
      # of the working directory path with the path of a freshly created tmp-directory.
      # TODO: Find a better way to test the creation of temporary directories
      tmp_dir = Pathname.new Dir.mktmpdir
      assert_equal tmp_dir.to_s[0..5], Path.work.to_s[0..5]
      # Cleanup
      assert Path.work.rmdir
      assert tmp_dir.rmdir
    end
    
    should "overwrite the --temp option when the --work-dir option is given" do
      Options.temp = true
      Options.work_dir = '/'
      @app.define_working_directory
      assert_equal '/', Path.work.to_s
    end

  end # context "An application instance"

end