require 'helper'
require 'ostruct'

class TestCommands < Test::Unit::TestCase
  
  include CSD
  
  DUMMY = %q{PART I

NIGHT

A high vaulted narrow Gothic chamber.
FAUST, restless, seated at his desk.

FAUST

I HAVE, alas! Philosophy,
Medicine, Jurisprudence too,
And to my cost Theology,
With ardent labour, studied through.
And here I stand, with all my lore,
Poor fool, no wiser than before.
Magister, doctor styled, indeed,
Already these ten years I lead,
Up, down, across, and to and fro,
My pupils by the nose,--and learn,
That we in truth can nothing know!}
  
  context "As a directory function" do
  
    setup do
      Options.silent = true
      Options.reveal = false
      Options.dry    = false
      @tmp    = Pathname.new Dir.mktmpdir
      @dir    = Pathname.new File.join(@tmp, 'folder')
      @subdir = Pathname.new File.join(@dir, 'subfolder')
    end

    teardown do
      assert FileUtils.rm_r(@tmp)
    end
    
    context "mkdir" do
  
      should "return the proper CommandResult if the directory already existed" do
        ensure_mkdir(@dir)
        assert_kind_of(CommandResult, result = Cmd.mkdir(@dir))
        assert result.success?
        assert result.already_existed?
        assert result.writable?
      end
      
      should "return a successful CommandResult but not actually do anything in reveal mode" do
        Options.reveal = true
        assert_kind_of(CommandResult, result = Cmd.mkdir(@dir))
        assert !@dir.directory?
        assert result.success?
        assert !result.already_existed?
        assert result.writable?
      end
      
      should "create the directory if it doesn't exist yet" do
        assert_kind_of(CommandResult, result = Cmd.mkdir(@dir))
        assert result.success?
        assert !result.already_existed?
        assert result.writable?
      end
      
      should "notify if there is no permission to create a new directory without die_on_failure" do
        ensure_mkdir(@dir)
        @dir.chmod(0000)
        assert_kind_of(CommandResult, result = Cmd.mkdir(File.join(@dir, 'subdir_in_readonly_dir'), :die_on_failure => false))
        assert !result.success?
        assert !result.already_existed?
        assert !result.writable?
        @dir.chmod(0777) # Cleanup
      end
      
      should "notify if there is no permission to create a new directory with die_on_failure" do
        ensure_mkdir(@dir)
        @dir.chmod(0000)
        assert_raise(Error::UI::Die) {
          Cmd.mkdir(File.join(@dir, 'subdir_in_readonly_dir'), :die_on_failure => true)
        }
        @dir.chmod(0777) # Cleanup
      end
      
      should "notify if there is no permission to create an existing directory" do
        ensure_mkdir(@dir)
        @dir.chmod(0000)
        assert_kind_of(CommandResult, result = Cmd.mkdir(@dir))
        assert result.success?
        assert result.already_existed?
        assert !result.writable?
        @dir.chmod(0777) # Cleanup
      end
      
    end # context "mkdir"

    context "cd" do
      
      should "return a CommanResult with success? if the directory was changed successfully" do
        assert_kind_of(CommandResult, result = Cmd.cd('/'))
        assert result.success?
        assert_kind_of(CommandResult, result = Cmd.cd(@tmp))
        assert result.success?
      end
      
      should "realize when the target is not a directory, but a file or something without die_on_failure" do
        testfile_path = File.join(@tmp, 'testfile')
        File.new(testfile_path, 'w')
        assert_kind_of(CommandResult, result = Cmd.cd(testfile_path, :die_on_failure => false))
        assert !result.success?
      end
      
      should "realize when the target is not a directory, but a file or something with die_on_failure" do
        testfile_path = File.join(@tmp, 'testfile')
        assert_raise(Error::UI::Die) {
          Cmd.cd(testfile_path, :die_on_failure => true)
        }
      end
      
      should "realize when the target doesn't exist without die_on_failure" do
        assert_kind_of(CommandResult, result = Cmd.cd('/i/for/sure/dont/exist', :die_on_failure => false))
        assert !result.success?
      end

      should "realize when the target doesn't exist with die_on_failure" do
        assert_raise(Error::UI::Die) {
          Cmd.cd('/i/for/sure/dont/exist', :die_on_failure => true)
        }
      end
      
      should "fake changing the directory in reveal mode" do
        Options.reveal = true
        current_pwd = Dir.pwd
        assert_kind_of(CommandResult, result = Cmd.cd('/i/for/sure/dont/exist'))
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
  
    context "when working with files" do
      
      setup do
        ensure_mkdir(@dir)
        ensure_mkdir(@subdir)
        @file1 = Pathname.new File.join(@tmp, 'file1')
        @file2 = Pathname.new File.join(@tmp, 'file2')
        @file3 = Pathname.new File.join(@dir, 'file3')
        [@file1, @file2, @file3].each { |file| assert FileUtils.touch(file) }
      end

      teardown do
        assert FileUtils.rm_r(@tmp)
        @tmp = Pathname.new Dir.mktmpdir
      end
      
      context "copy" do

        should "copy one file into another folder" do
          assert_kind_of(CommandResult, result = Cmd.copy(@file1, @subdir))
          assert result.success?
          assert File.exist?(File.join(@subdir, File.basename(@file1)))
        end

        should "copy several files into another folder" do
          assert_kind_of(CommandResult, result = Cmd.copy([@file1, @file2, @file3], @subdir))
          assert result.success?
          [@file1, @file2, @file3].each do |file|
            assert File.exist?(File.join(@subdir, File.basename(file)))
          end
        end
        
        should "know when a source file doesn't exist without die_on_failure" do
          assert_kind_of(CommandResult, result = Cmd.copy('/no/source', @subdir, :die_on_failure => false))
          assert !result.success?
        end
        
        should "know when a source file doesn't exist with die_on_failure" do
          assert_raise(Error::UI::Die) {
            Cmd.copy('/no/source', @subdir, :die_on_failure => true)
          }
        end
        
        should "know when a destination directory doesn't exist without die_on_failure" do
          assert_kind_of(CommandResult, result = Cmd.copy(@file1, '/no/destination', :die_on_failure => false))
          assert !result.success?
        end
        
        should "know when a destination directory doesn't exist with die_on_failure" do
          assert_raise(Error::UI::Die) {
            Cmd.copy(@file1, '/no/destination', :die_on_failure => true)
          }
        end
        
      end # context "copy"

      context "move" do

        should "move one file into another folder" do
          assert_kind_of(CommandResult, result = Cmd.move(@file1, @subdir))
          assert result.success?
          assert !File.exist?(@file1)
          assert File.exist?(File.join(@subdir, File.basename(@file1)))
        end

        should "move several files into another folder" do
          assert_kind_of(CommandResult, result = Cmd.move([@file1, @file2, @file3], @subdir))
          assert result.success?
          [@file1, @file2, @file3].each do |file|
            assert !File.exist?(file)
            assert File.exist?(File.join(@subdir, File.basename(file)))
          end
        end
        
        should "know when a source file doesn't exist without die_on_failure" do
          assert_kind_of(CommandResult, result = Cmd.move('/no/source', @subdir, :die_on_failure => false))
          assert !result.success?
        end

        should "know when a source file doesn't exist with die_on_failure" do
          assert_raise(Error::UI::Die) {
            Cmd.move('/no/source', @subdir, :die_on_failure => true)
          }
        end
        
        should "not mind when a destination doesn't exist even with die_on_failure" do
          assert_kind_of(CommandResult, result = Cmd.move(@file1, File.join(@subdir, 'newfile'), :die_on_failure => true))
          assert result.success?
          assert !File.exist?(@file1)
          assert File.exist?(File.join(@subdir, 'newfile'))
        end
        
      end # context "move"
      
      context "replace" do
      
        setup do
          File.open(@file1, 'w') { |f| assert f.write(DUMMY) }
        end

        should "be unsuccessful if the file doesn't exist without die_on_failure" do
          assert_kind_of(CommandResult, result = Cmd.replace('/i/am/not/there', 'FAUST', 'GOETHE', :die_on_failure => false))
          assert !result.success?
        end
        
        should "be unsuccessful if the file doesn't exist with die_on_failure" do
          assert_raise(Error::UI::Die) {
            Cmd.replace('/i/am/not/there', 'FAUST', 'GOETHE')
          }
        end
        
        should "do a simple replacement in a file" do
          assert_kind_of(CommandResult, result = Cmd.replace(@file1, 'FAUST', 'GOETHE'))
          assert result.success?
          assert_equal DUMMY.gsub('FAUST', 'GOETHE'), File.read(@file1)
        end
        
        should "do nothing if the file doesnt have anything to replace" do
          assert_kind_of(CommandResult, result = Cmd.replace(@file1, 'ASDF', 'FDSA'))
          assert_equal DUMMY, File.read(@file1)
          assert result.success?
        end
        
        should "replace multiple items in one file" do
          Cmd.replace @file1 do |r|
            assert_kind_of(CommandResult, r.replace('FAUST', 'GOETHE'))
            assert_equal DUMMY.gsub('FAUST', 'GOETHE'), File.read(@file1)
            assert_kind_of(CommandResult, r.replace("Philosophy,\n", 'Philosophy, '))
            assert File.read(@file1).scan('Philosophy, Medicine')
          end
        end
        
      end # context "replace"
      
    end # context "when working with files"
  
  end # context "As a directory function"
  
  context "run" do

    should "die on an invalid command" do
    end
    
  end

end
