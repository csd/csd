# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module FFmpeg
          class << self
            
            def compile
              UI.debug "#{self}.compile was called"
              if Path.ffmpeg_repository.directory? and !Options.reveal
                UI.warn "FFmpeg will not be processed because the directory #{Path.ffmpeg_repository.enquote} already exists."
              else
                checkout
                modify_libavutil if Options.ffmpeg_first
                make
              end
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
              Cmd.git_clone('ffmpeg repository', 'http://github.com/csd/ffmpeg.git', Path.ffmpeg_repository)
              Cmd.git_clone('ffmpeg libswscale sub-repository', 'http://github.com/csd/libswscale.git', Path.ffmpeg_libswscale)
            end
            
            # This flag is needed in order for stdint.h (by default in /usr/include) to define the constant +UINT64_C+.
            # If it does not do that, libavutil (part of FFmpeg) will not be accepted by +configure+ libminisip.
            # See http://code.google.com/p/ffmpegsource/issues/detail?id=11 for more other examples of this problem.
            #
            # *NOTE*: This flag actually does not work! That's what brings us to the next method: modify_libavutil
            #
            def c_flags
              %{CFLAGS="-D__STDC_CONSTANT_MACROS"}
            end
            
            # The constant +UINT64_C+ has not been provided by the operating system even though the
            # CFLAG "STDC_CONSTANT_MACROS" has been set. +UINT64_C+ should have been provided, but it was not.
            # Thus we hack here and assume that this constant is set to "ULL", which is default for an ix386 architecture.
            # In other words: This hack does not work on an amd-64 architecture. Yet it is only needed if FFmpeg
            # is compiled _before_ MiniSIP.
            #
            def modify_libavutil
              if Path.ffmpeg_libavutil_common_backup.file? and !Options.reveal
                UI.warn "The libavutil common.h file seems to be fixed already, I won't touch it now. Delete #{Path.ffmpeg_libavutil_common_backup.enquote} to enforce it."
              else
                UI.info "Modifying the FFmpeg source code".green.bold
                Cmd.copy Path.ffmpeg_libavutil_common, Path.ffmpeg_libavutil_common_backup
                Cmd.replace Path.ffmpeg_libavutil_common, '    if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;', "    // MODIFIED BY THE AUTOMATED INSTALLER\n    // if ((a+0x80000000u) & ~UINT64_C(0xFFFFFFFF)) return (a>>63) ^ 0x7FFFFFFF;\n    if ((a+0x80000000u) & ~(0xFFFFFFFFULL)) return (a>>63) ^ 0x7FFFFFFF;"
              end
            end
            
            # This method compiles FFmpeg, given that FFmpeg was downloaded before.
            #
            def make
              UI.info "Compiling and installing FFmpeg".green.bold
              Cmd.cd Path.ffmpeg_repository, :internal => true
              Cmd.run("#{c_flags} ./configure --enable-gpl --enable-libx264 --enable-x11grab")
              Cmd.run('make')
              Cmd.run('sudo checkinstall --pkgname=ffmpeg --pkgversion "99:-`git log -1 --pretty=format:%h`" --backup=no --default')
            end
            
          end
        end
      end
    end
  end
end
