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
        
        # CROSS-PLATFORM TASKS
        
        def libraries
          Options.only ? LIBRARIES.map { |lib| lib if Options.only.to_a.include?(lib) }.compact : LIBRARIES
        end
        
        def checkout_minisip
          Cmd.git_clone('MiniSIP repository', 'http://github.com/csd/minisip.git', Path.repository)
        end
        
        def modify_minisip
          Cmd.replace(Path.repository_open_gl_display, '/home/erik', Path.build)
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
        
        # CROSS-PLATFORM INFORMATION
        
        def minisip_cpp_flags
          "CPPFLAGS=\"-I#{Path.hdviper_x264} -I#{Path.hdviper_x264_test_x264api} -I#{Path.repository_grabber} -I#{Path.repository_decklinksdk}\""
        end
        
        def minisip_ld_flags
          "LDFLAGS=\"#{Path.hdviper_libx264api} #{Path.hdviper_libtidx264} -lpthread -lrt\""
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
          Path.work                               = Pathname.new(File.join(Path.root, 'minisip'))
          Path.giomm_header                       = Pathname.new(File.join('/', 'usr', 'include', 'giomm-2.4', 'giomm.h'))
          Path.giomm_header_backup                = Pathname.new(File.join('/', 'usr', 'include', 'giomm-2.4', 'giomm.h.ai-backup'))
          Path.repository                         = Pathname.new(File.join(Path.work, 'repository'))
          Path.repository_libminisip_rules        = Pathname.new(File.join(Path.repository, 'libminisip', 'debian', 'rules'))
          Path.repository_libminisip_rules_backup = Pathname.new(File.join(Path.repository, 'libminisip', 'debian', 'rules.ai-backup'))
          Path.repository_grabber                 = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'grabber'))
          Path.repository_open_gl_display         = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'display', 'OpenGLDisplay.cxx'))
          Path.repository_decklinksdk             = Pathname.new(File.join(Path.repository_grabber, 'decklinksdk'))
          Path.ffmpeg_repository                  = Pathname.new(File.join(Path.work, 'ffmpeg'))
          Path.ffmpeg_libswscale                  = Pathname.new(File.join(Path.ffmpeg_repository, 'libswscale'))
          Path.x264_repository                    = Pathname.new(File.join(Path.work, 'x264'))
          Path.plugins                            = Pathname.new(File.join(Path.work, 'plugins'))
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
        end
        
      end
    end
  end
end