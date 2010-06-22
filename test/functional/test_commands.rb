require 'helper'
require 'ostruct'

class Cmd
  include Csd::Commands
  attr_accessor :options
  def initialize
    @options = OpenStruct.new({ :silent => true, :quiet => true, :dry => false })
  end
end

class TestCommands < Test::Unit::TestCase
  
  context "As a directory function" do
  
    setup do
      @cmd    = Cmd.new
      @tmp    = Dir.mktmpdir
      @dir    = Pathname.new File.join(@tmp, 'folder')
      @subdir = Pathname.new File.join(@dir, 'subfolder')
    end

    teardown do
      FileUtils.rm_r(@tmp)
    end
    
    context "mkdir" do
  
      should "return the proper CommandResult if the directory already existed" do
        ensure_mkdir(@dir)
        assert_kind_of(Cmd::CommandResult, result = @cmd.mkdir(@dir))
        assert result.success?
        assert result.already_existed?
        assert result.writable?
      end
      
      should "return the proper CommandResult if the directory already existed in dry mode" do
        @cmd.options.dry = true
        ensure_mkdir(@dir)
        assert_kind_of(Cmd::CommandResult, result = @cmd.mkdir(@dir))
        assert result.success?
        assert result.already_existed?
        assert result.writable?
      end
      
      should "create the directory if it doesn't exist yet" do
        assert_kind_of(Cmd::CommandResult, result = @cmd.mkdir(@dir))
        assert result.success?
        assert !result.already_existed?
        assert result.writable?
      end
      
      should "create the directory if it doesn't exist yet in dry mode" do
        @cmd.options.dry = true
        assert_kind_of(Cmd::CommandResult, result = @cmd.mkdir(@dir))
        assert result.success?
        assert !result.already_existed?
        assert result.writable?
      end
      
      should "notify if there is no permission to create the directory" do
        ensure_mkdir(@dir)
        @dir.chmod(0000)
        assert_kind_of(Cmd::CommandResult, result = @cmd.mkdir(@dir))
        assert result.success?
        assert result.already_existed?
        assert !result.writable?
        Pathname.new(@dir).chmod(0777) # Cleanup
      end
      
    end # context "mkdir"

    context "cd" do
      
      should "return a CommanResult with success? if the directory was changed successfully" do
        assert_kind_of(Cmd::CommandResult, result = @cmd.cd('/'))
        assert result.success?
        assert_kind_of(Cmd::CommandResult, result = @cmd.cd(@tmp))
        assert result.success?
      end
      
      should "realize when the target is not a directory, but a file or something" do
        testfile_path = File.join(@tmp, 'testfile')
        File.new(testfile_path, 'w')
        assert_kind_of(Cmd::CommandResult, result = @cmd.cd(testfile_path))
        assert !result.success?
      end
      
      should "realize when the target doesn't exist" do
        assert_kind_of(Cmd::CommandResult, result = @cmd.cd('/i/for/sure/dont/exist'))
        assert !result.success?
      end
      
    end # context "cd"
  
  end # context "As a directory function"

end
