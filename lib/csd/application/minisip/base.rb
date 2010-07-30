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
        
        # This methods prints general information about this application module.
        #
        def introduction
          UI.separator
          UI.info " Working directory:       ".green.bold + Path.work.to_s.yellow
          unless Options.debug
            UI.info " Your Platform:           ".green + Gem::Platform.local.humanize.to_s.yellow
            UI.info(" Application module:      ".green + self.class.name.to_s.yellow)
          end
          UI.separator
          if Options.help
            UI.info Options.helptext
            # Cleanup in case the working directory was temporary and is empty
            Path.work.rmdir if Options.temp and Path.work.directory? and Path.work.children.empty?
            exit
          else
            raise Interrupt unless (Options.yes or Options.reveal or UI.continue?)
          end
        end
        
        # Defines all paths ever needed for the MiniSIP module based on the working directory.
        #
        def define_relative_paths
          Path.build                              = Pathname.new(File.join(Path.work, 'build'))
          Path.build_bin                          = Pathname.new(File.join(Path.build, 'bin'))
          Path.build_gtkgui                       = Pathname.new(File.join(Path.build_bin, 'minisip_gtkgui'))
          Path.build_include                      = Pathname.new(File.join(Path.build, 'include'))
          Path.build_lib                          = Pathname.new(File.join(Path.build, 'lib'))
          Path.build_lib_pkg_config               = Pathname.new(File.join(Path.build_lib, 'pkgconfig'))
          Path.build_share                        = Pathname.new(File.join(Path.build, 'share'))
          Path.build_share_aclocal                = Pathname.new(File.join(Path.build_share, 'aclocal'))
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
          Path.plugins                            = Pathname.new(File.join(Path.work, 'plugins'))
          Path.plugins_destination                = Pathname.new(File.join(Path.build_lib, 'libminisip', 'plugins'))
        end
        
      end
    end
  end
end