# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/base'

module CSD
  module Application
    module Minisip
      class Unix < Base
        
        # This method presents a general overview about the task that is to be performed.
        #
        def introduction
          Core.introduction
          super
        end
        
        # This method is called by the AI when the user requests the task "compile" for MiniSIP.
        #
        def compile
          UI.separator
          UI.info "This operation will download and compile MiniSIP.".green.bold
          introduction
          compile!
          run_minisip_gtk_gui
        end
        
        # This method is called by the AI when the user requests the task "package" for MiniSIP.
        #
        def package
          UI.separator
          UI.info("This operation will package ".green.bold + "an already compiled".red.bold + " MiniSIP.".green.bold)
          introduction
          package!
        end
        
        # This is the internal compile procedure for MiniSIP
        #
        def compile!
          Cmd.mkdir Path.work
          make_hdviper   unless checkout_hdviper.already_exists?
          modify_minisip unless checkout_minisip.already_exists?
          checkout_plugins
          if Options.ffmpeg_first
            make_x264 unless checkout_x264.already_exists?
            unless checkout_ffmpeg.already_exists?
              modify_libavutil
              checkout_libswscale
              make_ffmpeg
            end
            make_minisip
          else
            make_minisip
            make_x264 unless checkout_x264.already_exists?
            unless checkout_ffmpeg.already_exists?
              checkout_libswscale
              make_ffmpeg
            end
          end
          copy_plugins
        end
        
      end
    end
  end
end