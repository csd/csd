require 'helper'
require 'active_support/secure_random'

class TestPathname < Test::Unit::TestCase
  
  context "A normal Pathname object" do
  
    should "be enquotable" do
      assert_equal '"/"', Pathname.new('/').enquote
    end
    
    should "know if its the current pwd or not (regardless of the requested directory actually existing)" do
      Dir.chdir('/tmp')
      assert Pathname.new('/tmp').current_path?
      assert !Pathname.new('/i/do/not/exist').current_path?
    end
  
  end

  context "When working with directories" do
  
    setup do
      @tmp     = Dir.mktmpdir
      @subdirs = []
      5.times { @subdirs << File.join(@tmp, ActiveSupport::SecureRandom.hex(5)) }
      @subdirs.each { |subdir| ensure_mkdir(subdir) }
      @subdirs.map! { |subdir| Pathname.new(subdir)  }
    end

    teardown do
      assert FileUtils.rm_r(@tmp)
    end
    
    context "directories" do
  
      should "return all subdirectory names as an array" do
        result = Pathname.new(@tmp).children_directories.map { |pathname| pathname }
        assert_equal @subdirs.sort, result.sort
      end
      
      should "yield all subdirectories in a block" do
        result = []
        Pathname.new(@tmp).children_directories { |dir| result << dir }
        assert_equal @subdirs.sort, Pathname.new(@tmp).children_directories.sort
      end
      
    end # context "directories"
  
  end # context "When working with directories"
  
end
