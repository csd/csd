# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Minisip
      class Base < CSD::Application::Base
        
        LIBRARIES = %w{ libmutil libmnetutil libmcrypto libmikey libmsip libmstun libminisip minisip }
        
        # MAIN APPLICATION OPERATIONS
        
        def compile
          UI.error 'Currently not supported for this platform. Sorry.'
        end
        
        def package
          UI.error 'Currently not supported for this platform. Sorry.'
        end
        
        # GENERAL USER INFORMATION
        
        def introduction
          define_root_path
          define_paths
          UI.separator
          UI.info " Working directory:      ".green + Path.work.to_s.yellow
          UI.info " Your Platform:          ".green + Gem::Platform.local.humanize.to_s.yellow
          UI.info(" Application module:     ".green + self.class.name.to_s.yellow)
          UI.separator
          if Options.help
            UI.info Options.helptext
            exit
          else
            raise(Interrupt) unless (Options.yes or UI.ask_yes_no("Continue?".red.bold, true))
          end
        end
        
        # OTHER CROSS-PLATFORM TASKS
        
        # Determines which libraries of MiniSIP should be processed, given that the --only parameter might be set.
        #
        def libraries
          Options.only ? LIBRARIES.map { |lib| lib if Options.only.to_a.include?(lib) }.compact : LIBRARIES
        end

        # CHECKOUTS
        
        def checkout_minisip
          Cmd.git_clone('MiniSIP repository', 'http://github.com/csd/minisip.git', Path.repository)
        end
        
        def checkout_plugins
          Cmd.git_clone('additional MiniSIP plugins', 'http://github.com/csd/minisip-plugins.git', Path.plugins)
        end

        def checkout_hdviper
          Cmd.git_clone('HDVIPER', 'http://github.com/csd/libraries.git', Path.hdviper)
        end
        
        def checkout_ffmpeg
          Cmd.git_clone('ffmpeg repository', 'http://github.com/csd/ffmpeg.git', Path.ffmpeg_repository)
        end
        
        def checkout_libswscale
          Cmd.git_clone('ffmpeg libswscale sub-repository', 'http://github.com/csd/libswscale.git', Path.ffmpeg_libswscale)
        end
        
        def checkout_x264
          Cmd.git_clone('x264 repository', 'http://github.com/csd/x264.git', Path.x264_repository)
        end
        
        # MODIFYING FILES
        
        def modify_minisip
          Cmd.replace(Path.repository_open_gl_display, '/home/erik', Path.build)
          # See http://www.howgeek.com/2010/03/01/ffmpeg-php-error-‘pix_fmt_rgba32’-undeclared-first-use-in-this-function/
          # and http://ffmpeg.org/doxygen/0.5/pixfmt_8h.html#33d341c4f443d24492a95fb7641d0986
          Cmd.replace(Path.repository_avcoder_cxx,   'PIX_FMT_RGBA32', 'PIX_FMT_RGB32')
          Cmd.replace(Path.repository_avdecoder_cxx, 'PIX_FMT_RGBA32', 'PIX_FMT_RGB32')
        end
        
        def modify_libavutil
          return
          if Path.ffmpeg_libavutil_common_backup.file?
            UI.warn "The libavutil common.h file seems to be fixed already, I won't touch it now. Delete #{Path.ffmpeg_libavutil_common_backup.enquote} to enforce it."
          else
            Cmd.copy Path.ffmpeg_libavutil_common, Path.ffmpeg_libavutil_common_backup
            Cmd.replace Path.ffmpeg_libavutil_common, '    if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;', "    // MODIFIED BY THE AUTOMATED INSTALLER\n    // if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;\n    if ((a+0x80000000u) & ~(0xFFFFFFFFULL)) return (a>>63) ^ 0x7FFFFFFF;"
          end
        end
        
        # FLAGS
        
        # See http://code.google.com/p/ffmpegsource/issues/detail?id=11
        # But for some reason it did not fix tue issue for us :|
        #
        def libminisip_c_flags
          %{CFLAGS="-D__STDC_CONSTANT_MACROS"}
        end

        def libminisip_cpp_flags
          if Options.ffmpeg_first?
            %{CPPFLAGS="-I#{Path.hdviper_x264} -I#{Path.hdviper_x264_test_x264api} -I#{Path.ffmpeg_libavutil} -I#{Path.ffmpeg_libavcodec} -I#{Path.ffmpeg_libswscale} -I#{Path.repository_grabber} -I#{Path.repository_decklinksdk}"}
          else
            %{CPPFLAGS="-I#{Path.hdviper_x264} -I#{Path.hdviper_x264_test_x264api} -I#{Path.repository_grabber} -I#{Path.repository_decklinksdk}"}
          end
        end
        
        def libminisip_ld_flags
          %{LDFLAGS="#{Path.hdviper_libx264api} #{Path.hdviper_libtidx264} -lpthread -lrt"}
        end
        
        # DEFINING PATHS ETC...
        
        def define_root_path
          if Options.path
            if File.directory?(Options.path)
              Path.root = File.expand_path(Options.path)
            else
              raise Error::Options::PathNotFound, "The path `#{Options.path}´ doesn't exist."
            end
          else
            Path.root = Options.temp ? Dir.mktmpdir : Dir.pwd
          end
        end
        
        def define_paths
          Path.work                               = Pathname.new(File.join(Path.root, 'minisip.ai'))
          Path.giomm_header                       = Pathname.new(File.join('/', 'usr', 'include', 'giomm-2.4', 'giomm.h'))
          Path.giomm_header_backup                = Pathname.new(File.join('/', 'usr', 'include', 'giomm-2.4', 'giomm.h.ai-backup'))
          Path.repository                         = Pathname.new(File.join(Path.work, 'repository'))
          Path.repository_libminisip_rules        = Pathname.new(File.join(Path.repository, 'libminisip', 'debian', 'rules'))
          Path.repository_libminisip_rules_backup = Pathname.new(File.join(Path.repository, 'libminisip', 'debian', 'rules.ai-backup'))
          Path.repository_grabber                 = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'grabber'))
          Path.repository_open_gl_display         = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'display', 'OpenGLDisplay.cxx'))
          Path.repository_avcoder_cxx             = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'codec', 'AVCoder.cxx'))
          Path.repository_avdecoder_cxx           = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'codec', 'AVDecoder.cxx'))
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
          Path.build                              = Pathname.new(File.join(Path.work, 'build'))
          Path.build_bin                          = Pathname.new(File.join(Path.build, 'bin'))
          Path.build_gtkgui                       = Pathname.new(File.join(Path.build_bin, 'minisip_gtkgui'))
          Path.build_include                      = Pathname.new(File.join(Path.build, 'include'))
          Path.build_lib                          = Pathname.new(File.join(Path.build, 'lib'))
          Path.build_lib_pkg_config               = Pathname.new(File.join(Path.build_lib, 'pkgconfig'))
          Path.build_share                        = Pathname.new(File.join(Path.build, 'share'))
          Path.build_share_aclocal                = Pathname.new(File.join(Path.build_share, 'aclocal'))
          Path.plugins                            = Pathname.new(File.join(Path.work, 'plugins'))
          Path.plugins_destination                = Pathname.new(File.join(Path.build_lib, 'libminisip', 'plugins'))
        end
        
      end
    end
  end
end