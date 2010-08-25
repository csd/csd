# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/base'

module CSD
  module Application
    module Minisip
      class Unix < Base
        
        # This method presents a general overview about the task that is to be performed.
        #
        def introduction
          if Options.developer
            Core.introduction
            FFmpeg.introduction
            HDVIPER.introduction
            X264.introduction
            Plugins.introduction
            UI.separator
          end
          super
        end
        
        # This method is called by the AI when the user requests the task "compile" for MiniSIP.
        #
        def compile
          UI.separator
          UI.info "This operation will compile MiniSIP and its dependencies.".green.bold
          UI.separator
          install_mode = Options.this_user ? 'Only for this user (inside the working directory)' : 'For all users (sudo)'
          UI.info " Installation mode:       ".green.bold + install_mode.yellow
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
          Network.compile
          Gnome.compile
          congratulations
        end
        
        def congratulations
          if Options.this_user
            Core.run_gtkgui
          else
            cleanup_working_directory
            UI.separator
            UI.info "               MiniSIP installation complete.".green.bold
            UI.info "  Please have a look in your applications menu -> Internet."
            UI.separator
            # Core.run_gtkgui # At this point we could run MiniSIP instead of ending the AI -- if we wanted to.
          end
          
        end
        
      end
    end
  end
end