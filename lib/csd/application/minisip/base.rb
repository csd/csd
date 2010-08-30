# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'
require 'csd/application/minisip/component'

module CSD
  module Application
    module Minisip
      class Base < CSD::Application::Base
        
        include Component
        
        # Tasks to be done before the introduction is evoked by the AI.
        #
        def initialize
          super
          define_relative_paths
        end
        
        # Running the install task.
        # Currently this corresponds to the compile task.
        #
        def install
          compile
        end

        # Running the compile task.
        #
        def compile
          UI.error 'Currently not supported for this platform. Sorry.'
        end
        
        # Running the package task.
        #
        def package
          UI.error 'Currently not supported for this platform. Sorry.'
        end

        # Running the check task.
        #
        def check
          UI.error 'Currently not supported for this platform. Sorry.'
        end
        
        # Determines which components of MiniSIP should be processed, because the scope parameter might be set
        # by the user, requesting for only a particular component.
        #
        def components
          Options.scope ? [Options.scope] : Options.scopes_names
        end
        
        # Determine whether all components should be processed or not.
        #
        def all_components?
          components == Options.scopes_names
        end
        
        # Determines whether a particular component should be processed.
        #
        def component?(name)
          components.include? name
        end
        
        # This methods prints general information about this application module.
        #
        def introduction
          UI.info " Working directory:       ".green.bold + Path.work.to_s.yellow
          if Options.debug
            UI.info " Your Platform:           ".green + Gem::Platform.local.humanize.to_s.yellow
            UI.info(" Application module:      ".green + self.class.name.to_s.yellow)
          end
          UI.separator
          if Options.help
            UI.info Options.helptext
            # Cleanup in case the working directory was temporary and is empty
            Path.work.rmdir if Options.temp and Path.work.directory? and Path.work.children.empty?
            raise CSD::Error::Argument::HelpWasRequested
          else
            raise Interrupt unless Options.yes or Options.reveal or UI.continue?
          end
        end
        
        # Defines all paths ever needed for the MiniSIP module based on the working directory.
        #
        def define_relative_paths
          UI.debug "#{self.class}#define_relative_paths defines relative MiniSIP paths now"
          if Options.this_user
            Path.build = Pathname.new(File.join(Path.work, 'build'))
          else
            Path.build = Pathname.new(File.join('/', 'usr', 'local'))
            # This is tricky, but should work for most linux distributions
            # On Windows it will just crash here, unless we determine where the heck sudo make install is targetting at :)
            raise Error::Minisip::BuildDirNotFound, "Sorry, `/usr/local´ could not be found but was requested as MiniSIP target. Use `#{CSD.executable}´ with the option `--this-user´ instead." unless Path.build.directory?
          end
          Path.build_bin                          = Pathname.new(File.join(Path.build, 'bin'))
          Path.build_gtkgui                       = Pathname.new(File.join(Path.build_bin, 'minisip_gtkgui'))
          Path.build_include                      = Pathname.new(File.join(Path.build, 'include'))
          Path.build_lib                          = Pathname.new(File.join(Path.build, 'lib'))
          Path.build_lib_libminisip_so            = Pathname.new(File.join(Path.build_lib, 'libminisip.so.0'))
          Path.build_lib_pkg_config               = Pathname.new(File.join(Path.build_lib, 'pkgconfig'))
          Path.build_share                        = Pathname.new(File.join(Path.build, 'share'))
          Path.build_share_aclocal                = Pathname.new(File.join(Path.build_share, 'aclocal'))
          Path.giomm_header                       = Pathname.new(File.join('/', 'usr', 'include', 'giomm-2.4', 'giomm.h'))
          Path.giomm_header_backup                = Pathname.new(File.join('/', 'usr', 'include', 'giomm-2.4', 'giomm.h.ai-backup'))
          Path.repository                         = Pathname.new(File.join(Path.work, 'minisip'))
          Path.repository_libminisip_rules        = Pathname.new(File.join(Path.repository, 'libminisip', 'debian', 'rules'))
          Path.repository_libminisip_rules_backup = Pathname.new(File.join(Path.repository, 'libminisip', 'debian', 'rules.ai-backup'))
          Path.repository_grabber                 = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'grabber'))
          Path.repository_open_gl_display         = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'display', 'OpenGLDisplay.cxx'))
          Path.repository_avcoder_cxx             = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'codec', 'AVCoder.cxx'))
          Path.repository_avdecoder_cxx           = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'codec', 'AVDecoder.cxx'))
          Path.repository_sip_conf                = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_signaling', 'sip', 'SipSoftPhoneConfiguration.cxx'))
          Path.repository_decklinksdk             = Pathname.new(File.join(Path.repository_grabber, 'decklinksdk'))
          Path.ffmpeg_repository                  = Pathname.new(File.join(Path.work, 'ffmpeg'))
          Path.ffmpeg_libavutil                   = Pathname.new(File.join(Path.ffmpeg_repository, 'libavutil'))
          Path.ffmpeg_libavutil_common            = Pathname.new(File.join(Path.ffmpeg_libavutil, 'common.h'))
          Path.ffmpeg_libavutil_common_backup     = Pathname.new(File.join(Path.ffmpeg_libavutil, 'common.h.ai-backup'))
          Path.ffmpeg_libavcodec                  = Pathname.new(File.join(Path.ffmpeg_repository, 'libavcodec'))
          Path.ffmpeg_libswscale                  = Pathname.new(File.join(Path.ffmpeg_repository, 'libswscale'))
          Path.x264_repository                    = Pathname.new(File.join(Path.work, 'x264'))
          Path.packaging                          = Pathname.new(File.join(Path.work, 'packaging'))
          Path.hdviper                            = Pathname.new(File.join(Path.work, 'hdviper'))
          Path.hdviper_x264                       = Pathname.new(File.join(Path.hdviper, 'x264'))
          Path.hdviper_libtidx264                 = Pathname.new(File.join(Path.hdviper_x264, 'libtidx264.a'))
          Path.hdviper_x264_test_x264api          = Pathname.new(File.join(Path.hdviper_x264, 'test', 'x264API'))
          Path.hdviper_libx264api                 = Pathname.new(File.join(Path.hdviper_x264_test_x264api, 'libx264api.a'))
          Path.plugins                            = Pathname.new(File.join(Path.work, 'plugins'))
          Path.plugins_destination                = Pathname.new(File.join(Path.build_lib, 'libminisip', 'plugins'))
          Path.minisip_gnome_png                  = Pathname.new(File.join(Path.repository, 'minisip', 'share', 'icon_gnome.png'))
          Path.minisip_gnome_pixmap               = Pathname.new(File.join('/', 'usr', 'share', 'pixmaps', 'minisip_gnome.png'))
          Path.minisip_desktop_entry              = Pathname.new(File.join('/', 'usr', 'share', 'applications', 'minisip.desktop'))
          Path.phonebook                          = Pathname.new(File.join(ENV['HOME'], '.minisip.addr'))
          Path.realtek_firmware                   = Pathname.new(File.join(Path.work, 'realtek'))
          Path.intel_firmware                     = Pathname.new(File.join(Path.work, 'intel'))
          Path.intel_firmware_src                 = Pathname.new(File.join(Path.intel_firmware, 'src'))
          Path.sysctl_conf                        = Pathname.new(File.join('/', 'etc', 'sysctl.conf'))
          Path.sysctl_conf_backup                 = Pathname.new(File.join('/', 'etc', 'sysctl.conf.ai-backup'))
          Path.new_sysctl_conf                    = Pathname.new(File.join(Path.work, 'sysctl.conf'))
        end
        
      end
    end
  end
end