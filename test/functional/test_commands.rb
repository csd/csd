require 'helper'
require 'ostruct'

class TestCommands < Test::Unit::TestCase
  
  include CSD
  
  context "As a directory function" do
  
    setup do
      Options.silent = true
      Options.reveal = false
      Options.dry    = false
      @tmp    = Dir.mktmpdir
      @dir    = Pathname.new File.join(@tmp, 'folder')
      @subdir = Pathname.new File.join(@dir, 'subfolder')
    end

    teardown do
      assert FileUtils.rm_r(@tmp)
    end
    
    context "mkdir" do
  
      should "return the proper CommandResult if the directory already existed" do
        ensure_mkdir(@dir)
        assert_kind_of(Commands::CommandResult, result = Cmd.mkdir(@dir))
        assert result.success?
        assert result.already_existed?
        assert result.writable?
      end
      
      should "return a successful CommandResult but not actually do anything in reveal mode" do
        Options.reveal = true
        assert_kind_of(Commands::CommandResult, result = Cmd.mkdir(@dir))
        assert !@dir.directory?
        assert result.success?
        assert !result.already_existed?
        assert result.writable?
      end
      
      should "return a failing CommandResult but not actually do anything in dry mode" do
        Options.dry = true
        assert_kind_of(Commands::CommandResult, result = Cmd.mkdir(@dir))
        assert !@dir.directory?
        assert !result.success?
        assert !result.already_existed?
        assert !result.writable?
      end
      
      should "create the directory if it doesn't exist yet" do
        assert_kind_of(Commands::CommandResult, result = Cmd.mkdir(@dir))
        assert result.success?
        assert !result.already_existed?
        assert result.writable?
      end
      
      should "notify if there is no permission to create the directory" do
        ensure_mkdir(@dir)
        @dir.chmod(0000)
        assert_kind_of(Commands::CommandResult, result = Cmd.mkdir(@dir))
        assert result.success?
        assert result.already_existed?
        assert !result.writable?
        @dir.chmod(0777) # Cleanup
      end
      
    end # context "mkdir"

    context "cd" do
      
      should "return a CommanResult with success? if the directory was changed successfully" do
        assert_kind_of(Commands::CommandResult, result = Cmd.cd('/'))
        assert result.success?
        assert_kind_of(Commands::CommandResult, result = Cmd.cd(@tmp))
        assert result.success?
      end
      
      should "realize when the target is not a directory, but a file or something" do
        testfile_path = File.join(@tmp, 'testfile')
        File.new(testfile_path, 'w')
        assert_kind_of(Commands::CommandResult, result = Cmd.cd(testfile_path))
        assert !result.success?
      end
      
      should "realize when the target doesn't exist" do
        assert_kind_of(Commands::CommandResult, result = Cmd.cd('/i/for/sure/dont/exist'))
        assert !result.success?
      end
      
      should "fake changing the directory in reveal mode" do
        Options.reveal = true
        current_pwd = Dir.pwd
        assert_kind_of(Commands::CommandResult, result = Cmd.cd('/i/for/sure/dont/exist'))
        assert result.success?
        assert_equal current_pwd, Dir.pwd
      end
      
      should "actually change the directory in dry mode" do
        Options.dry = true
        assert_not_equal '/', Dir.pwd
        assert result = Cmd.cd('/')
        assert result.success?
        assert_equal '/', Dir.pwd
      end
      
    end # context "cd"
  
  end # context "As a directory function"

end
