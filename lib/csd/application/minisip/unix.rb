# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/base'

module CSD
  module Application
    module Minisip
      class Unix < Base
        
        # OPERATION INTRODUCTION
        
        def introduction
          UI.separator
          UI.info " Libraries to process:   ".green + libraries.join(', ').yellow
          super
        end
        
        def compile
          UI.separator
          UI.info "This operation will download and compile MiniSIP.".green.bold
          introduction
          compile!
          run_minisip_gtk_gui
        end
        
        def package
          UI.separator
          UI.info("This operation will package ".green.bold + "an already compiled".red.bold + " MiniSIP.".green.bold)
          introduction
          package!
        end
        
        # OPERATIONS
        
        def compile!
          Cmd.mkdir Path.work
          make_hdviper unless checkout_hdviper.already_exists?
          make_x264    unless checkout_x264.already_exists?
          unless checkout_ffmpeg.already_exists?
            checkout_libswscale
            make_ffmpeg
          end
          checkout_minisip
          checkout_plugins
          modify_minisip
          make_minisip
        end
        
        def make_ffmpeg
          Cmd.cd Path.ffmpeg_repository, :internal => true
          Cmd.run('./configure --enable-gpl --enable-pthreads --enable-libx264 --enable-x11grab')
          Cmd.run('make')
          Cmd.run('sudo checkinstall --pkgname=ffmpeg --pkgversion "4:ai-`git log -1 --pretty=format:%h`" --backup=no --default')
        end
        
        def make_x264
          Cmd.cd Path.x264_repository, :internal => true
          Cmd.run('./configure')
          Cmd.run('make')
          Cmd.run('sudo checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default')
        end
        
        def make_hdviper
          Cmd.cd Path.hdviper_x264, :internal => true
          Cmd.run('./configure')
          Cmd.run('make')
          Cmd.cd Path.hdviper_x264_test_x264api, :internal => true
          Cmd.run('make')
        end
        
        def create_build_dir
          UI.info "Creating target build directories".green.bold
          [Path.build, Path.build_include, Path.build_lib, Path.build_share, Path.build_share_aclocal].each { |target| Cmd.mkdir target }
        end
        
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
                    %Q{--enable-debug --enable-video --disable-mil --enable-decklink --enable-opengl --disable-sdl CPPFLAGS="-I#{Path.hdviper_x264_test_x264api} -I#{Path.hdviper_x264}" #{minisip_ld_flags}}
                    #%Q{--enable-debug --enable-video --disable-mil --disable-decklink --enable-opengl --disable-sdl CPPFLAGS="-I#{Path.hdviper_x264}" LDFLAGS="#{File.join(Path.hdviper_x264, 'libx264.a')} -lpthread -lrt"}
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
        
        def run_minisip_gtk_gui
          Cmd.run(Path.build_gtkgui, :die_on_failure => false)
        end
        
      end
    end
  end
end