require 'helper'
require 'active_support/secure_random'

class TestDir < Test::Unit::TestCase
  
  include CSD
  
  context "When working with directories" do
  
    setup do
      @tmp     = Dir.mktmpdir
      @subdirs = []
      5.times { @subdirs << ActiveSupport::SecureRandom.hex(5) }
      @subdirs.each { |subdir| ensure_mkdir(File.join(@tmp, subdir)) }
    end

    teardown do
      assert FileUtils.rm_r(@tmp)
    end
    
    context "directories" do
  
      should "return all subdirectory names as an array" do
        result = Dir.directories(@tmp).map { |dirname| dirname }
        assert_equal @subdirs.sort, result.sort
      end
      
      should "yield all subdirectories in a block" do
        result = []
        Dir.directories(@tmp) { |dir| result << dir }
        assert_equal @subdirs.sort, Dir.directories(@tmp).sort
      end
      
    end # context "directories"
  
  end # context "When working with directories"
  
end
