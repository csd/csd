# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/phonebook_example'
require 'csd/application/minisip/component/core_packaging'

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
            
            include Packaging

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
              ensure_ati_vsync
            end
            
            def remove_ffmpeg
              ffmpeg_available = Cmd.run('ffmpeg -h', :internal => true, :die_on_failure => false).success?
              return if Options.ffmpeg_first or !libraries.include?('libminisip') or !ffmpeg_available
              UI.debug "MILESTONE_removing_ffmpeg"
              if Gem::Platform.local.debian?
                # Note that FFmpeg must have been installed via apt-get or via the AI in order for this to work,
                # because manual compilations of FFmpeg cannot be removed automatically
                UI.info "Removing FFmpeg before re-compiling MiniSIP".green.bold
                UI.info "You can skip this step by giving the option --force-ffmpeg".yellow
                Cmd.run "sudo apt-get remove ffmpeg --yes", :announce_pwd => false
              else
                # On other linux distributions we don't know how to remove ffmpeg
                UI.debug "MILESTONE_cannot_remove_ffmpeg"
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
              # The untested version from the vendor was requested
              return checkout_from_vendor if Options.vendor
              Cmd.git_clone 'MiniSIP repository', 'http://github.com/csd/minisip.git', Path.repository
              # Note that the command above will checkout the master branch.
              # In that case we are not allowed to checkout the master branch again.
              if Options.branch and Options.branch != 'master'
                Cmd.cd Path.repository, :internal => true
                Cmd.run "git checkout -b #{Options.branch} origin/#{Options.branch}"
              end
              UI.info "Initializing any optional git submodules".green.bold
              Cmd.cd Path.repository, :internal => true
              Cmd.run 'git submodule init'
              Cmd.run 'git submodule update'
            end
            
            def checkout_from_vendor
              Cmd.cd Path.work, :internal => true
              Cmd.run "svn checkout svn://svn.minisip.org/minisip/trunk minisip"
            end
            
            # Some places in the MiniSIP source code have to be modified before MiniSIP can be compiled.
            # * An absolute path must be replaced with the current absolute prefix path in
            #   <tt>libminisip/source/subsystem_media/video/display/OpenGLDisplay.cxx</tt>
            # * The .minisip.conf configuration file generated by MiniSIP has a SIP proxy server by default.
            #   The configuration _key_ is $proxy_addr$ and the _value_ is $sip.domain.example$. We modify
            #   the source code file responsible for generating the default configuration file, so that it will
            #   not fill in a SIP proxy server by default. The reason is that during compilation there is no 
            #   .minisip.conf file that we could edit! So we go for the source.
            # * Modifications of some constants will be done, because this is more compatible
            #   with the most recent FFmpeg version. In fact, MiniSIP won't compile if FFmpeg is present
            #   and this has not been modified. See http://www.howgeek.com/2010/03/01/ffmpeg-php-error-‘pix_fmt_rgba32’-undeclared-first-use-in-this-function
            #   and http://ffmpeg.org/doxygen/0.5/pixfmt_8h.html#33d341c4f443d24492a95fb7641d0986 for more information
            #   about the FFmpeg pixel format constants.
            #
            def modify_source_code
              UI.info "Fixing MiniSIP OpenGL GUI source code".green.bold
              # Replacing the hardcoded path in the OpenGLDisplay.cxx
              Cmd.replace Path.repository_open_gl_display, /\tstring path = "(.+)"\+/, %{\tstring path = "#{Path.build}"+}
              UI.info "Modifying default MiniSIP configuration parameters".green.bold
              # Removing the default SIP proxy server from the Configuration generator
              Cmd.replace Path.repository_sip_conf, 'sip.domain.example', ''
              # We would like decklink to be the default video device
              Cmd.replace Path.repository_sip_conf, 'be->commit();', %{be->save("video_device", "decklink:0/720p50@25");be->commit();}
              # Switching logging to ON as default, as opposed to OFF
              Cmd.replace Path.repository_sip_conf, 'be->saveBool("logging",false)', 'be->saveBool("logging",true)'
              if Options.ffmpeg_first
                UI.info "Fixing MiniSIP Audio/Video en/decoder source code".green.bold
                Cmd.replace Path.repository_avcoder_cxx,   'PIX_FMT_RGBA32', 'PIX_FMT_RGB32'
                Cmd.replace Path.repository_avdecoder_cxx, 'PIX_FMT_RGBA32', 'PIX_FMT_RGB32'
              end
              modify_libminisip_rules
            end
            
            def modify_libminisip_rules
              if Path.repository_libminisip_rules_backup.file?
                UI.warn "The libminisip rules seem to be fixed already, I won't touch them now. Delete #{Path.repository_libminisip_rules_backup.enquote} to enforce it."
              else
                Cmd.copy Path.repository_libminisip_rules, Path.repository_libminisip_rules_backup
                Cmd.replace Path.repository_libminisip_rules, 'AUTOMATED_INSTALLER_PLACEHOLDER=""', [libminisip_cpp_flags, libminisip_ld_flags].join(' ')
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
              return if Options.this_user
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
              UI.debug "MILESTONE_processing_libraries"
              libraries.each do |library|
                directory = Pathname.new(File.join(Path.repository, library))
                if Cmd.cd(directory, :internal => true).success? or Options.reveal
                  UI.debug "MILESTONE_processing_#{library}"
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
                  %Q{--enable-video --enable-opengl --disable-mil --enable-decklink --disable-sdl #{libminisip_cpp_flags} #{libminisip_ld_flags}}
                when 'minisip'
                  %Q{--enable-video --enable-opengl --enable-textui}
                else
                  ''
              end
              # The --enable-debug option should only be there if specifically requested
              debug_options = '--enable-debug' if Options.enable_debug
              # These options are used by all libraries
              common_options = %Q{--prefix="#{Path.build}" PKG_CONFIG_PATH="#{Path.build_lib_pkg_config}" ACLOCAL_FLAGS="#{Path.build_share_aclocal}" LD_LIBRARY_PATH="#{Path.build_lib}"} if Options.this_user
              # I2conf needs to compile MiniSIP without any options
              individual_options = nil if Options.blank_minisip_configuration
              # Putting it all together
              Cmd.run ['./configure', common_options, debug_options, individual_options].compact.join(' ')
            end
            
            def make
              make! if Options.make
            end
            
            def make!
              Cmd.run("make -j 15")
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
            
            def create_address_book
              return unless !Path.phonebook.file? or ::CSD::Application::Minisip::OUTDATED_PHONEBOOKS.include?(File.read(Path.phonebook).hashed)
              UI.info "Creating default MiniSIP phonebook".green.bold
              Cmd.mkdir Path.phonebook_dir
              Cmd.touch_and_replace_content Path.phonebook, ::CSD::Application::Minisip::PHONEBOOK_EXAMPLE, :internal => true
              UI.info "  Phonebook successfully saved in #{Path.phonebook}".yellow
            end
            
            # This method is agreeably a little bit out of place. Because this technically should happen whenever
            # the graphic card drivers are installed and not when MiniSIP is installed. However, the AI is not present
            # when the graphic card drivers are installed (because then X11 is booted down and the AI process is
            # replaced by the proprietary ATI or nVidia installation process). So we better make sure at this point,
            # that the vertical synching for ATI graphic cards is switched on.
            #
            # The reason why we want this is because otherwise we will have vertical lines in the video. It is commonly
            # referred to as "teared images" and is caused by the monitor having a Hertz rate of 60Hz, while OpenGL has
            # a rate of about 400Hz. So the screen picture might be refreshed by OpenGL *while* the monitor is doing his
            # own refresh. This will result in a horizontal line on the screen. When they are synchronized, OpenGL will
            # be reduced to about 59Hz and the video will be clear. This information was obtained by Erik, the vendor
            # of MiniSIP.
            #
            def ensure_ati_vsync
              # Return if no ATI drivers are installed
              return unless Path.catalyst_config.file?
              UI.info "Ensuring AMD vertical synchronization between OpenGL and Monitor".green.bold
              Cmd.run "sudo aticonfig --set-pcs-u32=BUSID-2:0:0-0/OpenGL,VSyncControl,2", :announce_pwd => false
            end
            
          end
        end
      end
    end
  end
end