# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module FFmpeg
          class << self
          
            def introduction
            end
          
            def checkout
              UI.debug "#{self}: checkout"
              Cmd.git_clone('ffmpeg repository', 'http://github.com/csd/ffmpeg.git', Path.ffmpeg_repository)
              Cmd.git_clone('ffmpeg libswscale sub-repository', 'http://github.com/csd/libswscale.git', Path.ffmpeg_libswscale)
            end
          
            def modify_libavutil
              if Path.ffmpeg_libavutil_common_backup.file?
                UI.warn "The libavutil common.h file seems to be fixed already, I won't touch it now. Delete #{Path.ffmpeg_libavutil_common_backup.enquote} to enforce it."
              else
                Cmd.copy Path.ffmpeg_libavutil_common, Path.ffmpeg_libavutil_common_backup
                Cmd.replace Path.ffmpeg_libavutil_common, '    if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;', "    // MODIFIED BY THE AUTOMATED INSTALLER\n    // if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;\n    if ((a+0x80000000u) & ~(0xFFFFFFFFULL)) return (a>>63) ^ 0x7FFFFFFF;"
              end
            end
          
            # This method compiles FFmpeg, given that FFmpeg was downloaded before.
            #
            def make_ffmpeg
              Cmd.cd Path.ffmpeg_repository, :internal => true
              Cmd.run('./configure --enable-gpl --enable-libx264 --enable-x11grab')
              Cmd.run('make')
              Cmd.run('sudo checkinstall --pkgname=ffmpeg --pkgversion "99:-`git log -1 --pretty=format:%h`" --backup=no --default')
            end
          
          end
        end
      end
    end
  end
end
