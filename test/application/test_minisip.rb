require 'helper'
require 'csd/application/minisip'

class TestMinisip < Test::Unit::TestCase
  
  include CSD
  include Application::Minisip::Component
  
  context "MiniSIP's" do

    setup do
      Options.clear
      @default_minisip_options = Application::Minisip.options
    end

    context "Core component" do
      
      setup do
        @base = Application::Minisip::Base.new
        @base.define_relative_paths
        #CSD.options.eval @default_minisip_options
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

      context "in theory" do

        setup do
          Options.clear
          Options.reveal = true
        end

        should "know how to checkout the default branch of the source code" do
          out, err = capture { Core.checkout }
          assert_match /git clone /, out
          assert_no_match /git pull/, out
          assert err.empty?
        end
      
        should "know how to checkout a particular branch of the source code" do
          Options.branch = 'cuttingedge'
          out, err = capture { Core.checkout }
          assert_match /git clone /, out
          assert_match /git pull .+ cuttingedge/, out
          assert err.empty?
        end
      
        should "use sudo make install instead of make install by default" do
          Options.make_install = true
          out, err = capture { Core.compile }
          # TODO: This should be a more strict test
          assert_match /sudo make install/, out
        end
      
        should "description" do
          out, err = capture { Core.compile }
          #puts out
        
        end

      end # context "in theory"

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
