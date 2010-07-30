# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module FFmpeg
          class << self
            
            def compile
              return if Path.ffmpeg_repository.directory?
              checkout
              modify if Options.ffmpeg_first # TODO: This can problbably be deleted now, because of the CPPFLAGS
              make
            end
            
            def introduction
              if Path.ffmpeg_repository.directory?
                UI.debug "There is no FFmpeg introduction, because the directory already exists: #{Path.ffmpeg_repository.enquote}"
              else
                UI.info " FFmpeg (incl. libswscale)".green.bold
                UI.info "  - downloading to:       ".green + Path.ffmpeg_repository.to_s.yellow
                UI.info "  - compiling".green
              end
            end
            
            def checkout
              UI.debug "#{self}: checkout"
              Cmd.git_clone('ffmpeg repository', 'http://github.com/csd/ffmpeg.git', Path.ffmpeg_repository)
              Cmd.git_clone('ffmpeg libswscale sub-repository', 'http://github.com/csd/libswscale.git', Path.ffmpeg_libswscale)
            end
            
            def modify
              if Path.ffmpeg_libavutil_common_backup.file?
                UI.warn "The libavutil common.h file seems to be fixed already, I won't touch it now. Delete #{Path.ffmpeg_libavutil_common_backup.enquote} to enforce it."
              else
                Cmd.copy Path.ffmpeg_libavutil_common, Path.ffmpeg_libavutil_common_backup
                Cmd.replace Path.ffmpeg_libavutil_common, '    if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;', "    // MODIFIED BY THE AUTOMATED INSTALLER\n    // if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;\n    if ((a+0x80000000u) & ~(0xFFFFFFFFULL)) return (a>>63) ^ 0x7FFFFFFF;"
              end
            end
            
            def c_flags
              %{CFLAGS="-D__STDC_CONSTANT_MACROS"}
            end
            
            # This method compiles FFmpeg, given that FFmpeg was downloaded before.
            #
            def make
              UI.info "Compiling and installing FFmpeg".green.bold
              Cmd.cd Path.ffmpeg_repository, :internal => true
              Cmd.run("./configure --enable-gpl --enable-libx264 --enable-x11grab #{c_flags}")
              Cmd.run('make')
              Cmd.run('sudo checkinstall --pkgname=ffmpeg --pkgversion "99:-`git log -1 --pretty=format:%h`" --backup=no --default')
            end
            
          end
        end
      end
    end
  end
end
