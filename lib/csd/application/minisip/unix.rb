# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/base'

module CSD
  module Application
    module Minisip
      class Unix < Base
        
        # This method presents a general overview about the task that is to be performed.
        #
        def introduction
          UI.separator
          UI.info " MiniSIP libraries to process:   ".green + libraries.join(', ').yellow
          super
        end
        
        # This method is called by the AI when the user requests the task "compile" for MiniSIP.
        #
        def compile
          UI.separator
          UI.info "This operation will download and compile MiniSIP.".green.bold
          introduction
          compile!
          run_minisip_gtk_gui
        end
        
        # This method is called by the AI when the user requests the task "package" for MiniSIP.
        #
        def package
          UI.separator
          UI.info("This operation will package ".green.bold + "an already compiled".red.bold + " MiniSIP.".green.bold)
          introduction
          package!
        end
        
        # This is the internal compile procedure for MiniSIP
        #
        def compile!
          Cmd.mkdir Path.work
          make_hdviper   unless checkout_hdviper.already_exists?
          modify_minisip unless checkout_minisip.already_exists?
          checkout_plugins
          if Options.ffmpeg_first
            make_x264 unless checkout_x264.already_exists?
            unless checkout_ffmpeg.already_exists?
              modify_libavutil
              checkout_libswscale
              make_ffmpeg
            end
            make_minisip
          else
            make_minisip
            make_x264 unless checkout_x264.already_exists?
            unless checkout_ffmpeg.already_exists?
              checkout_libswscale
              make_ffmpeg
            end
          end
          copy_plugins
        end
        
        # This method compiles FFmpeg, given that FFmpeg was downloaded before.
        #
        def make_ffmpeg
          Cmd.cd Path.ffmpeg_repository, :internal => true
          Cmd.run('./configure --enable-gpl --enable-libx264 --enable-x11grab')
          Cmd.run('make')
          Cmd.run('sudo checkinstall --pkgname=ffmpeg --pkgversion "99:-`git log -1 --pretty=format:%h`" --backup=no --default')
        end
        
        # This method compiles x264, given that x264 was downloaded before.
        #
        def make_x264
          Cmd.cd Path.x264_repository, :internal => true
          Cmd.run('./configure')
          Cmd.run('make')
          Cmd.run('sudo checkinstall --pkgname=x264 --pkgversion "99:-`git log -1 --pretty=format:%h`" --backup=no --default')
        end
        
        # This method compiles HDVIPER, given that HDVIPER was downloaded before.
        #
        def make_hdviper
          Cmd.cd Path.hdviper_x264, :internal => true
          Cmd.run('./configure')
          Cmd.run('make')
          Cmd.cd Path.hdviper_x264_test_x264api, :internal => true
          Cmd.run('make')
        end
        
        # Creates all build directories such as +lib+, +share+, +bin+, etc.
        #
        def create_build_dir
          UI.info "Creating target build directories".green.bold
          [Path.build, Path.build_include, Path.build_lib, Path.build_share, Path.build_share_aclocal].each { |target| Cmd.mkdir target }
        end
        
        # Copies the plugins from the repository to the final destination.
        #
        def copy_plugins
          UI.info "Creating plugin target directory".green.bold
          # result = Path.plugins_destination.parent.directory? ? Cmd.run("sudo mkdir #{Path.plugins_destination}") : CommandResult.new
          # TODO: This will maybe need sudo rights in the future
          Cmd.copy(Dir[File.join('Path.plugins', '*.{l,la,so}')], Path.plugins_destination) if Path.plugins_destination.directory?
        end
        
        # Iteratively configures and compiles the internal MiniSIP libraries.
        #
        def make_minisip
          create_build_dir
          libraries.each do |library|
            directory = Pathname.new(File.join(Path.repository, library))
            next if Options.only and !Options.only.include?(library)
            if Cmd.cd(directory) or Options.reveal
              if Options.bootstrap
                UI.info "Bootstrapping #{library}".green.bold
                Cmd.run("./bootstrap -I #{Path.build_share_aclocal.enquote}")
              end
              if Options.configure
                UI.info "Configuring #{library}".green.bold
                individual_options = case library
                  when 'libminisip'
                    %Q{--enable-debug --enable-video --disable-mil --enable-decklink --enable-opengl --disable-sdl #{libminisip_c_flags} #{libminisip_cpp_flags} #{libminisip_ld_flags}}
                  when 'minisip'
                    %Q{--enable-debug --enable-video --enable-textui --enable-opengl}
                  else
                    ''
                end
                Cmd.run(%Q{./configure #{individual_options} --prefix=#{Path.build.enquote} PKG_CONFIG_PATH=#{Path.build_lib_pkg_config.enquote} ACLOCAL_FLAGS=#{Path.build_share_aclocal} LD_LIBRARY_PATH=#{Path.build_lib.enquote}})
              end
              if Options.make
                UI.info "Make #{library}".green.bold
                Cmd.run("make")
              end
              if Options.make_install
                maker_command = Options.make_dist ? 'dist' : 'install'
                UI.info "Make #{maker_command} #{library}".green.bold
                Cmd.run("make #{maker_command}")
              end
            else
              UI.warn "Skipping minisip library #{library} because it not be found: #{directory}".green.bold
            end
          end
        end
        
        # Iteratively makes debian packages of the internal MiniSIP libraries.
        #
        def package!
          Cmd.mkdir(Path.packaging)
          libraries.each do |library|
            directory = Pathname.new(File.join(Path.repository, library))
            next if Options.only and !Options.only.include?(library)
            UI.info "Making #{library} with target dist".green.bold
            if Cmd.cd(directory) or Options.reveal
              Cmd.run("make dist")
              
              tar_filename = File.basename(Dir[File.join(directory, '*.tar.gz')].first)
              Cmd.move(File.join(directory, tar_filename.to_s), Path.packaging) if tar_filename or Options.reveal
              
              if Cmd.cd(Path.packaging) or Options.reveal
                Cmd.run("tar -xzf #{tar_filename}")
                tar_dirname = File.basename(tar_filename.to_s, '.tar.gz')
                if Cmd.cd(File.join(Path.packaging, tar_dirname))
                  Cmd.run("dpkg-buildpackage -rfakeroot")
                  if library == 'minisip'
                    if Cmd.cd(Path.packaging)
                      package = File.basename(Dir[File.join(Path.packaging, "#{library}*.deb")].first)
                      Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                    end
                  else
                    if Cmd.cd(Path.packaging)
                      package = File.basename(Dir[File.join(Path.packaging, "#{library}0*.deb")].first)
                      Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                      dev_package = File.basename(Dir[File.join(Path.packaging, "#{library}-dev*.deb")].first)
                      Cmd.run("sudo dpkg -i #{dev_package}") if dev_package or Options.reveal
                    end
                  end
                else
                  UI.error "Could not enter #{File.join(Path.packaging, tar_dirname)}."
                end
                
              else
                UI.error "Could not enter #{Path.packaging}."
              end
                
            else
              UI.error "Could not enter #{directory}."
            end
          end
          Cmd.cd Path.root
          Cmd.run('minisip_gtk_gui')
        end
        
        # Executed the MiniSIP GTK GUI.
        #
        def run_minisip_gtk_gui
          Cmd.run(Path.build_gtkgui, :die_on_failure => false)
        end
        
      end
    end
  end
end