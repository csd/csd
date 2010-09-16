require 'helper'
require 'csd/application/minisip'

class TestMinisip < Test::Unit::TestCase
  
  include CSD
  include Application::Minisip::Component
  
  context "MiniSIP's" do

    setup do
      Options.clear
      Options.testmode = true
    end
    
    context "Debian instance" do
      
      setup do
        @debian = ::CSD::Application::Minisip::Debian.new
      end

      context "*in theory* when compiling" do

        setup do
          Options.clear
          @debian.define_relative_paths
          Options.clear Application::Minisip.default_options('install')
          Options.reveal = true
          Options.testmode = true
        end
        
        should "by default run apt-get commands" do
          assert Options.apt_get
          out, err = capture { @debian.compile! }
          assert_match /apt\-get update/, out
          assert_match /apt\-get install/, out
        end
        
        should "skip apt-get if demanded" do
          Options.apt_get = false
          out, err = capture { @debian.compile! }
          assert_no_match /apt\-get/, out
        end
      
      end
    end

    context "Core component" do
      
      setup do
        @base = Application::Minisip::Base.new
      end

      should "know how to identify and sort a subset of internal MiniSIP libraries with --only" do
        Options.only = nil
        assert_equal Core::LIBRARIES, Core.libraries
        Options.only = %w{ libmcrypto }
        assert_equal %w{ libmcrypto }, Core.libraries
        Options.only = %w{ does-not-exist }
        assert Core.libraries == []
        Options.only = Core::LIBRARIES
        assert_equal Core::LIBRARIES, Core.libraries
        Options.only = %w{ minisip libmutil }
        assert_equal %w{ libmutil minisip }, Core.libraries
      end

      context "*in theory* when compiling" do

        setup do
          Options.clear
          @base.define_relative_paths
          Options.clear Application::Minisip.default_options('install')
          Options.reveal = true
          Options.testmode = true
        end

        should "by default use all minisip compiling options" do
          assert Options.bootstrap
          assert Options.configure
          assert Options.make
          assert Options.make_install
        end
        
        should "know how to checkout the default branch of the source code" do
          Options.branch = nil
          out, err = capture { Core.checkout }
          assert_match /git clone /, out
          assert_no_match /git pull/, out
          assert_no_match /git checkout/, out
          assert err.empty?
        end
        
        should "know how to checkout a particular branch of the source code" do
          Options.branch = 'cuttingedge'
          out, err = capture { Core.checkout }
          assert_match /git clone /, out
          assert_match /git checkout .+ cuttingedge/, out
          assert err.empty?
        end
        
        should "use sudo make install instead of make install by default" do
          out, err = capture { Core.compile }
          # TODO: This should be a more strict test
          assert_match /sudo make install/, out
        end
      
        should "proclaim that it was called in debug mode" do
          Options.debug = true
          out, err = capture { Core.compile }
          assert_match /Minisip::Component::Core\.compile was called/, out
        end
        
        should "remove ffmpeg before compiling minisip" do
          Options.debug = true
          out, err = capture { Core.compile }
          assert_match /MILESTONE_removing_ffmpeg.+MILESTONE_processing_libminisip/m, out
          assert_no_match /MILESTONE_processing_libminisip.+MILESTONE_removing_ffmpeg/m, out
        end
        
        should "not link the library in this-user-mode" do
          out, err = capture { Core.compile }
          assert_match /ldconfig/, out
          Options.this_user=true
          out, err = capture { Core.compile }
          assert_no_match /ldconfig/, out
        end
        
        should "process libraries without parameters when demanded" do
          Options.debug = true
          Options.blank_minisip_configuration = true
          out, err = capture { Core.compile_libraries }
          assert_match /MILESTONE_processing_libmstun/, out
          assert_match /MILESTONE_processing_libminisip/, out
          assert_match /MILESTONE_processing_minisip/, out
          assert_no_match /FLAGS/, out 
          assert_no_match /enable/, out 
        end

        should "have no --enable-debug flag by default" do
          Options.debug = true
          out, err = capture { Core.compile_libraries }
          assert_no_match /enable\-debug/, out
        end
        
        should "use --enable-debug flag if demanded" do
          Options.debug = true
          Options.enable_debug = true
          out, err = capture { Core.compile_libraries }
          # We will check or the flag before and after the milestone to go sure it's everywhere
          assert_match /MILESTONE_processing_libminisip.+\-\-enable\-debug.+MILESTONE_processing_minisip.+\-\-enable\-debug/m, out
          assert_match /\-\-enable\-debug.+MILESTONE_processing_libminisip/m, out
        end
        
      end # context "in theory when compiling"

      context "in practice" do

        if ONLINE

          setup do
            Options.clear
          end

        end # if ONLINE

      end # context "in practice"

    end # context "Core component"
    
  end # context "MiniSIP's"
  
end
