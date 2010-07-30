# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Core
          class << self
            
            # This is an +Array+ containing the names of the internal MiniSIP libraries. Note that they
            # are sorted according to the sequence in which they need to be compiled.
            #
            LIBRARIES = %w{ libmutil libmnetutil libmcrypto libmikey libmsip libmstun libminisip minisip }
            
            # Prints information about how Minisip will be processed.
            #
            def introduction
              UI.info " MiniSIP libraries to process: ".green + Minisip.libraries.join(', ').yellow
            end
            
            # Determines which libraries of MiniSIP should be processed, because the --only parameter might be set.
            #
            def libraries
              Options.only ? LIBRARIES.map { |lib| lib if Options.only.to_a.include?(lib) }.compact : LIBRARIES
            end
            
            # See http://code.google.com/p/ffmpegsource/issues/detail?id=11
            # But for some reason it did not fix tue issue for us :|
            #
            def libminisip_c_flags
              %{CFLAGS="-D__STDC_CONSTANT_MACROS"}
            end

            def libminisip_cpp_flags
              if Options.ffmpeg_first
                %{CPPFLAGS="-I#{Path.hdviper_x264} -I#{Path.hdviper_x264_test_x264api} -I#{Path.ffmpeg_libavutil} -I#{Path.ffmpeg_libavcodec} -I#{Path.ffmpeg_libswscale} -I#{Path.repository_grabber} -I#{Path.repository_decklinksdk}"}
              else
                %{CPPFLAGS="-I#{Path.hdviper_x264} -I#{Path.hdviper_x264_test_x264api} -I#{Path.repository_grabber} -I#{Path.repository_decklinksdk}"}
              end
            end
            
            def libminisip_ld_flags
              %{LDFLAGS="#{Path.hdviper_libx264api} #{Path.hdviper_libtidx264} -lpthread -lrt"}
            end
            
            def checkout_minisip
              Cmd.git_clone('MiniSIP repository', 'http://github.com/csd/minisip.git', Path.repository)
            end
            
            def modify_minisip
              Cmd.replace(Path.repository_open_gl_display, '/home/erik', Path.build)
              if Options.ffmpeg_first
                # See http://www.howgeek.com/2010/03/01/ffmpeg-php-error-‘pix_fmt_rgba32’-undeclared-first-use-in-this-function/
                # and http://ffmpeg.org/doxygen/0.5/pixfmt_8h.html#33d341c4f443d24492a95fb7641d0986
                Cmd.replace(Path.repository_avcoder_cxx,   'PIX_FMT_RGBA32', 'PIX_FMT_RGB32')
                Cmd.replace(Path.repository_avdecoder_cxx, 'PIX_FMT_RGBA32', 'PIX_FMT_RGB32')
              end
            end
            
            # Iteratively processes the internal MiniSIP libraries (+bootstrap+, +configure+, +make+, +make install+).
            #
            def make_minisip
              create_build_dir
              libraries.each do |library|
                directory = Pathname.new(File.join(Path.repository, library))
                if Cmd.cd(directory) or Options.reveal
                  UI.info "Processing #{library}".green.bold
                  bootstrap
                  configure library
                  make
                  make_install
                else
                  UI.warn "Skipping MiniSIP library #{library} because it could not be found in #{directory.enquote}"
                end
              end
            end
            
            # Creates all build directories such as +lib+, +share+, +bin+, etc.
            #
            def create_build_dir
              # In sudo mode, we don't need to create these. They already exist in the OS.
              return if superuser?
              UI.info "Creating target build directories".green.bold
              [Path.build, Path.build_include, Path.build_lib, Path.build_share, Path.build_share_aclocal].each { |target| Cmd.mkdir target }
            end
            
            # This method runs the `bootstrap´ command in the current directory unless --no-bootstrap was given.
            # It is only used for the internal MiniSIP libraries.
            #
            def bootstrap
              boostrap! if Options.bootstrap
            end
            
            # This method forces running the `bootstrap´ command in the current directory.
            # It is only used for the internal MiniSIP libraries.
            #
            def bootstrap!
              if superuser?
                Cmd.run("./bootstrap")
              else
                Cmd.run("./bootstrap -I #{Path.build_share_aclocal.enquote}")
              end
            end
            
            def configure(name='')
              configure! name if Options.configure
            end
            
            def configure!(name='')
              individual_options = case name
                when 'libminisip'
                  %Q{--enable-debug --enable-video --enable-opengl --disable-mil --enable-decklink --disable-sdl #{libminisip_c_flags} #{libminisip_cpp_flags} #{libminisip_ld_flags}}
                when 'minisip'
                  %Q{--enable-debug --enable-video --enable-opengl --enable-textui}
                else
                  ''
              end
              common_options = superuser? ? %Q{--prefix=#{Path.build.enquote} PKG_CONFIG_PATH=#{Path.build_lib_pkg_config.enquote} ACLOCAL_FLAGS=#{Path.build_share_aclocal} LD_LIBRARY_PATH=#{Path.build_lib.enquote}} : ''
              Cmd.run ['./configure', common_options, individual_options].join(' ')
            end
            
            def make
              make! if Options.make
            end
            
            def make!
              Cmd.run("make")
            end
            
            def make_install
              make_install! if Options.make_install
            end
            
            def make_install!
              Cmd.run("make install")
            end
          
            # Executed the MiniSIP GTK GUI.
            #
            def run_minisip_gtk_gui
              Cmd.run(Path.build_gtkgui, :die_on_failure => false)
            end
          
            # Iteratively makes debian packages of the internal MiniSIP libraries.
            # TODO: Refactor this, it looks terribly sensitive.
            # TODO: Check for GPL and LGLP license conflicts.
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
              Cmd.cd '/'
              Cmd.run('minisip_gtk_gui')
            end

          end
        end
      end
    end
  end
end