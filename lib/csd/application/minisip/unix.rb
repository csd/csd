# encoding: utf-8
require File.join(File.dirname(__FILE__), 'base')

module CSD
  module Application
    module Minisip
      class Unix < Base
        
        def package
          define_root_path
          define_paths
          #compile
          package!
        end
        
        def compile
          define_root_path
          define_paths
          fix_ubuntu_10_04 and return if Options.only_fix_giomm
          UI.separator
          UI.info "This operation will download and compile MiniSIP.".green.bold
          UI.separator
          UI.info " Working directory:   ".green + Path.work.to_s.yellow
          UI.info " Your Platform:       ".green + Gem::Platform.local.humanize.to_s.yellow
          UI.info(" Application module:  ".green + self.class.name.to_s.yellow) if Options.developer
          UI.separator
          if Options.help
            UI.info Options.helptext
          else
            unless Options.yes
              exit unless UI.ask_yes_no("Continue?".red.bold, true)
            end
            compile!
          end
          UI.separator
        end
        
        def make_hdviper
          Cmd.cd Path.hdviper_x264
          Cmd.run('./configure')
          Cmd.run('make')
          Cmd.cd Path.hdviper_x264_test_x264api
          Cmd.run('make')
        end
        
        def make_minisip
          [Path.build, Path.build_include, Path.build_lib, Path.build_share, Path.build_share_aclocal].each { |target| Cmd.mkdir target }
          LIBRARIES.each do |library|
            directory = Pathname.new(File.join(Path.repository, library))
            next if Options.only and !Options.only.include?(library)
            if Cmd.cd(directory) or Options.dry or Options.reveal
              if Options.bootstrap
                UI.info "Bootstrapping #{library}".green.bold
                Cmd.run("./bootstrap -I #{Path.build_share_aclocal.enquote}", :die_on_failure => true)
              end
              if Options.configure
                UI.info "Configuring #{library}".green.bold
                individual_options = case library
                  when 'libminisip'
                    %Q{--enable-debug --enable-video --disable-mil --enable-decklink --enable-opengl --disable-sdl CPPFLAGS="-I#{Path.hdviper_x264_test_x264api} -I#{Path.hdviper_x264}" LDFLAGS="#{File.join(Path.hdviper_x264_test_x264api, 'libx264api.a')} #{File.join(Path.hdviper_x264, 'libtidx264.a')} -lpthread -lrt"}
                    #%Q{--enable-debug --enable-video --disable-mil --disable-decklink --enable-opengl --disable-sdl CPPFLAGS="-I#{Path.hdviper_x264}" LDFLAGS="#{File.join(Path.hdviper_x264, 'libx264.a')} -lpthread -lrt"}
                  when 'minisip'
                    %Q{--enable-debug --enable-video --enable-textui --enable-opengl}
                  else
                    ''
                end
                Cmd.run(%Q{./configure #{individual_options} --prefix=#{Path.build.enquote} PKG_CONFIG_PATH=#{Path.build_lib_pkg_config.enquote} ACLOCAL_FLAGS=#{Path.build_share_aclocal} LD_LIBRARY_PATH=#{Path.build_lib.enquote} --silent}, :die_on_failure => true)
              end
              if Options.make
                UI.info "Make #{library}".green.bold
                Cmd.run("make", :die_on_failure => true)
              end
              if Options.make_install
                maker_command = Options.make_dist ? 'dist' : 'install'
                UI.info "Make #{maker_command} #{library}".green.bold
                Cmd.run("make #{maker_command}", :die_on_failure => true)
              end
            else
              UI.warn "Skipping minisip library #{library} because it not be found: #{directory}".green.bold
            end
          end
        end
        
        def package!
          LIBRARIES.each do |library|
            directory = Pathname.new(File.join(Path.repository, library))
            next if Options.only and !Options.only.include?(library)
            UI.info "Making #{library} with target dist".green.bold
            if Cmd.cd(directory) or Options.dry or Options.reveal
              Cmd.run("make dist", :die_on_failure => true)
              
              tar_filename = Dir[File.join(directory, '*.tar.gz')].first
              Cmd.move(File.join(directory, tar_filename.to_s), Path.packaging) if tar_filename or Options.reveal
              
              if Cmd.cd(Path.packaging) or Options.dry or Options.reveal
                Cmd.run("tar -xzf #{tar_filename}", :die_on_failure => true)
                tar_dirname = File.basename(tar_filename.to_s, '.tar.gz')
                if Cmd.cd(File.join(Path.packaging, tar_dirname))
                  Cmd.run("dpkg-buildpackage -rfakeroot", :die_on_failure => true)
                  if library == 'minisip'
                    package = Dir[File.join(Path.packaging, "#{library}*.deb")].first
                    Cmd.run("sudo apt-get install #{package}", :die_on_failure => true) if package or Options.reveal
                  else
                    dev_package = Dir[File.join(Path.packaging, "#{library}-dev*.deb")].first
                    Cmd.run("sudo apt-get install #{dev_package}", :die_on_failure => true) if dev_package or Options.reveal
                    package = Dir[File.join(Path.packaging, "#{library}0*.deb")].first
                    Cmd.run("sudo apt-get install #{package}", :die_on_failure => true) if package or Options.reveal
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
          Cmd.run 'minisip_gtkgui'
        end
        
      end
    end
  end
end