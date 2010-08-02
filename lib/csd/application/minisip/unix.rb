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
          # FFmpeg.introduction
          # HDVIPER.introduction
          # X264.introduction
          # Plugins.introduction
          super
        end
        
        # This method is called by the AI when the user requests the task "compile" for MiniSIP.
        #
        def compile
          UI.separator
          UI.info "This operation will compile MiniSIP and its dependencies.".green.bold
          UI.separator
          introduction
          compile!
        end
        
        # This method is called by the AI when the user requests the task "package" for MiniSIP.
        #
        def package
          UI.separator
          UI.info("This operation will package ".green.bold + "an already compiled".red.bold + " MiniSIP.".green.bold)
          introduction
          package!
        end
        
        # This is the internal compile procedure for MiniSIP and its components.
        #
        def compile!
          create_working_directory
          HDVIPER.compile
          if Options.ffmpeg_first
            X264.compile
            FFmpeg.compile
            Core.compile
          else
            Core.compile
            X264.compile
            FFmpeg.compile
          end
          Plugins.compile
          Core.run_gtk_gui
        end
        
      end
    end
  end
end