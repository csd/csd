require 'helper'
require 'ostruct'
require 'tmpdir'

class TestApplicationBase < Test::Unit::TestCase
  
  include CSD
  
  context "An application instance" do
  
    setup do
      Options.clear
      @app = Application::Base.new
    end
    
    should "use a temporary directory as working directory when the --temp options is given" do
      Options.temp = true
      @app.define_working_directory
      assert_kind_of Pathname, Path.work
      # We verify whether this is a tempory directory by comparing the first six characters
      # of the working directory path with the path of a freshly created tmp-directory.
      # TODO: Find a better way to test the creation of temporary directories
      tmp_dir = Pathname.new Dir.mktmpdir
      assert_equal tmp_dir.to_s[0..5], Path.work.to_s[0..5]
      # Cleanup
      assert Path.work.rmdir
      assert tmp_dir.rmdir
    end
    
    should "accept a manual working directory parameter" do
      Options.work_dir = '/my/cool/working/dir'
      @app.define_working_directory
      assert_kind_of Pathname, Path.work
      assert_equal '/my/cool/working/dir', Path.work.to_s
    end
    
    should "overwrite the --temp option when the --work-dir option is given" do
      Options.temp = true
      Options.work_dir = '/'
      @app.define_working_directory
      assert_kind_of Pathname, Path.work
      assert_equal '/', Path.work.to_s
    end
    
    should "take the current pwd with a subdirectory in the name of the application as working directory by default" do
      @app.define_working_directory
      assert_kind_of Pathname, Path.work
      assert_equal File.join(Dir.pwd, "application.ai"), Path.work.to_s
    end
    
  end # context "An application instance"

end