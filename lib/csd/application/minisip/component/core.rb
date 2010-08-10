# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/phonebook_example'

module CSD
  module Application
    module Minisip
      # This namespace is reserved for sub-components of this application. This is done for better readability and modularity
      # (i.e. less risky to fail in production).
      #
      module Component
        # This MiniSIP component is the very minisip source code itself.
        #
        module Core
          
          # This is an +Array+ containing the names of the internal MiniSIP libraries. Note that they
          # are sorted according to the sequence in which they need to be compiled (because they depend on each other).
          #
          LIBRARIES = %w{ libmutil libmnetutil libmcrypto libmikey libmsip libmstun libminisip minisip }
          
          class << self
            
            # This method processes the MiniSIP Core component and does everything needed for compiling it. Note that
            # it is not responsible for checking depenencies here. It will just focus on compiling the internal MiniSIP libraries.
            #
            def compile
              UI.debug "#{self}.compile was called"
              UI.debug "The current Options are: #{::CSD.options.inspect_for_debug}"
              remove_ffmpeg
              if Path.repository.directory? and !Options.reveal
                UI.warn "The MiniSIP source code will not be downloaded, because the directory #{Path.repository.enquote} already exists."
              else
                checkout
                modify_source_code
              end
              modify_dirlist
              compile_libraries # We would like to re-compile MiniSIP no matter what options were given as command-line arguments.
              link_libraries
              create_address_book
            end
            
            def remove_ffmpeg
              ffmpeg_available = Cmd.run('ffmpeg -h', :internal => true, :die_on_failure => false).success?
              return if Options.ffmpeg_first or !Options.configure or !libraries.include?('libminisip') or !ffmpeg_available
              UI.debug "MILESTONE: removing_ffmpeg"
              if Gem::Platform.local.debian?
                # Note that FFmpeg must have been installed via apt-get or via the AI in order for this to work,
                # because manual compilations of FFmpeg cannot be removed automatically
                UI.info "Removing FFmpeg before re-compiling MiniSIP".green.bold
                UI.info "You can skip this step by giving the option --force-ffmpeg".yellow
                Cmd.run "sudo apt-get remove ffmpeg --yes", :announce_pwd => false
              else
                # On other linux distributions we don't know how to remove ffmpeg
                UI.debug "MILESTONE: cannot_remove_ffmpeg"
                raise Error::Minisip::Core::FFmpegInstalled, "Please remove ffmpeg from your system first, or run the #{CSD.executable} with --no-configure" unless Options.testmode
              end
            end
            
            # This method provides upfront information to the user about how the MiniSIP Core component will be processed.
            #
            def introduction
              UI.info " MiniSIP".green.bold
              # If the repository directory already exists, we indicate that here
              download_text = Path.repository.directory? ? "  - located at:           " : "  - downloading to:       "
              UI.info download_text.green + Path.repository.to_s.yellow
              # Now let's present which libraries will be compiled with which commands
              UI.info "  - libraries to process: ".green + libraries.join(', ').yellow
              UI.info "  - with these commands:  ".green + [('bootstrap' if Options.bootstrap), ('configure' if Options.configure), ('make' if Options.make), ('make install' if Options.make_install)].compact.join(', ').yellow
            end
            
            # Determines which libraries of MiniSIP should be processed, because the --only parameter might be set
            # by the user, requesting for only a subset of the libraries.
            #
            def libraries
              Options.only ? LIBRARIES.map { |lib| lib if Options.only.to_a.include?(lib) }.compact : LIBRARIES
            end
            
            # This method downloads the minisip source code in the right version. If the <tt>Options.branch</tt>
            # parameter is set to a branchname of the source code repository, that branch will be downloaded. Currently
            # this function uses the intermediary Github repository to make sure that
            # * the downloaded version is not a risky cutting-edge trunk
            # * the download works even if the vendor's repository is down (again)
            # That means that the Github repository (or any other intermediary repository) should be manually updated
            # by an TTA AI developer, after having made sure that that source code version is working properly.
            #
            def checkout
              Cmd.git_clone 'MiniSIP repository', 'http://github.com/csd/minisip.git', Path.repository
              if Options.branch
                Cmd.cd Path.repository, :internal => true
                Cmd.run "git pull origin #{Options.branch}"
              end
            end
            
            # Some places in the MiniSIP source code have to be modified before it can be compiled.
            # In this case, an absolute path must be replaced with the current absolute prefix path.
            # Furthermore, modifications of some constants will be done, because this is more compatible
            # with the most recent FFmpeg version. In fact, MiniSIP won't compile if FFmpeg is present
            # and this has not been modified.
            # See http://www.howgeek.com/2010/03/01/ffmpeg-php-error-‘pix_fmt_rgba32’-undeclared-first-use-in-this-function
            # and http://ffmpeg.org/doxygen/0.5/pixfmt_8h.html#33d341c4f443d24492a95fb7641d0986 for more information.
            #
            def modify_source_code
              UI.info "Fixing MiniSIP OpenGL GUI source code".green.bold
              Cmd.replace(Path.repository_open_gl_display, '/home/erik', Path.build)
              if Options.ffmpeg_first
                UI.info "Fixing MiniSIP Audio/Video en/decoder source code".green.bold
                Cmd.replace(Path.repository_avcoder_cxx,   'PIX_FMT_RGBA32', 'PIX_FMT_RGB32')
                Cmd.replace(Path.repository_avdecoder_cxx, 'PIX_FMT_RGBA32', 'PIX_FMT_RGB32')
              end
            end
            
            # Usually, Ubuntu ignores <tt>/usr/local/share/aclocal</tt>. So we need to create a file called
            # +dirlist+ in <tt>/usr/share/aclocal</tt> which contains the path to the other directory.
            #
            def modify_dirlist
              Path.dirlist = Pathname.new File.join('/', 'usr', 'share', 'aclocal', 'dirlist')
              if !Path.dirlist.file? and Gem::Platform.local.debian? or Options.reveal
                UI.info "Fixing broken Debian aclocal path".green.bold
                Path.new_dirlist = Pathname.new File.join(Path.work, 'dirlist')
                Cmd.touch_and_replace_content Path.new_dirlist, '/usr/local/share/aclocal'
                Cmd.run "sudo mv #{Path.new_dirlist} #{Path.dirlist}", :announce_pwd => false
              end
            end
            
            def link_libraries
              UI.info "Linking shared MiniSIP libraries".green.bold
              Cmd.run "sudo ldconfig #{Path.build_lib_libminisip_so}", :announce_pwd => false
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
            
            # Iteratively processes the internal MiniSIP libraries (+bootstrap+, +configure+, +make+, +make install+).
            #
            def compile_libraries
              create_build_dir
              libraries.each do |library|
                directory = Pathname.new(File.join(Path.repository, library))
                if Cmd.cd(directory, :internal => true).success? or Options.reveal
                  UI.debug "MILESTONE: processing_#{library}"
                  UI.info "Processing MiniSIP -> #{library}".green.bold
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
              return unless Options.this_user
              UI.info "Creating target build directories".green.bold
              [Path.build, Path.build_include, Path.build_lib, Path.build_share, Path.build_share_aclocal].each { |target| Cmd.mkdir target }
            end
            
            # This method runs the `bootstrap´ command in the current directory unless --no-bootstrap was given.
            # It is only used for the internal MiniSIP libraries.
            #
            def bootstrap
              bootstrap! if Options.bootstrap
            end
            
            # This method forces running the `bootstrap´ command in the current directory.
            # It is only used for the internal MiniSIP libraries.
            #
            def bootstrap!
              if Options.this_user
                Cmd.run(%Q{./bootstrap -I "#{Path.build_share_aclocal}"})
              else
                Cmd.run("./bootstrap")
              end
            end
            
            def configure(name='')
              configure! name if Options.configure
            end
            
            def configure!(name='')
              individual_options = case name
                when 'libminisip'
                  %Q{--enable-debug --enable-video --enable-opengl --disable-mil --enable-decklink --disable-sdl #{libminisip_cpp_flags} #{libminisip_ld_flags}}
                when 'minisip'
                  %Q{--enable-debug --enable-video --enable-opengl --enable-textui}
                else
                  ''
              end
              common_options = Options.this_user ? %Q{--prefix="#{Path.build}" PKG_CONFIG_PATH="#{Path.build_lib_pkg_config}" ACLOCAL_FLAGS="#{Path.build_share_aclocal}" LD_LIBRARY_PATH="#{Path.build_lib}"} : ''
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
              if Options.this_user
                Cmd.run("make install")
              else
                Cmd.run("sudo make install")
              end
            end
            
            # Execute the MiniSIP GTK GUI.
            #
            def run_gtkgui
              UI.info "Executing MiniSIP".green.bold
              if Options.this_user
                Cmd.run Path.build_gtkgui, :die_on_failure => false, :announce_pwd => false
              else
                Cmd.run 'minisip_gtkgui', :die_on_failure => false, :announce_pwd => false
              end
            end
            
            def modify_libminisip_rules
              if Path.repository_libminisip_rules_backup.file?
                UI.warn "The libminisip rules seem to be fixed already, I won't touch them now. Delete #{Path.repository_libminisip_rules_backup.enquote} to enforce it."
              else
                Cmd.copy Path.repository_libminisip_rules, Path.repository_libminisip_rules_backup
                Cmd.replace Path.repository_libminisip_rules, 'AUTOMATED_INSTALLER_PLACEHOLDER=""', [libminisip_cpp_flags, libminisip_ld_flags].join(' ')
              end
            end
            
            def create_address_book
              return if Path.phonebook.file?
              UI.info "Creating default MiniSIP phonebook".green.bold
              Cmd.touch_and_replace_content Path.phonebook, ::CSD::Application::Minisip::PHONEBOOK_EXAMPLE, :internal => true
              UI.info "  Phonebook successfully saved in #{Path.phonebook}".yellow
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
              Cmd.run('minisip_gtkgui')
            end
            
          end
        end
      end
    end
  end
end