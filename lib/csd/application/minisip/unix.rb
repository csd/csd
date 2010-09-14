# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/base'

module CSD
  module Application
    module Minisip
      class Unix < Base
        
        # This method presents a general overview about the task that is to be performed.
        #
        def introduction
          UI.debug "Components to be processed: #{components.inspect}"
          if Options.developer
            Core.introduction    if component? 'core'
            FFmpeg.introduction  if component? 'ffmpeg'
            HDVIPER.introduction if component? 'hdviper'
            X264.introduction    if component? 'x264'
            Plugins.introduction if component? 'plugins'
            UI.separator
          end
          super
        end
        
        # This method is called by the AI when the user requests the task "compile" for MiniSIP.
        #
        def compile
          UI.separator
          if all_components?
            UI.info "This operation will install MiniSIP and its dependencies.".green.bold
          else
            UI.info "This operation will install the #{Options.scope} component of MiniSIP.".green.bold
          end
          UI.separator
          install_mode = Options.this_user ? 'Only for this user (inside the working directory)' : 'For all users (sudo)'
          UI.info " Installation mode:       ".green.bold + install_mode.yellow
          introduction
          compile!
        end
        
        # This method is called by the AI when the user requests the task "package" for MiniSIP.
        #
        def package
          Core.package
        end
        
        # This is the internal compile procedure for MiniSIP and its components.
        #
        def compile!
          create_working_directory
          HDVIPER.compile          if component? 'hdviper'
          if Options.ffmpeg_first
            X264.compile           if component? 'x264'
            FFmpeg.compile         if component? 'ffmpeg'
            Core.compile           if component? 'core'
          else
            Core.compile           if component? 'core'
            X264.compile           if component? 'x264'
            FFmpeg.compile         if component? 'ffmpeg'
          end
          Plugins.compile          if component? 'plugins'
          Network.compile          if component? 'network'
          Gnome.compile            if component? 'gnome'
          congratulations
        end
        
        def congratulations
          if Options.this_user
            Core.run_gtkgui
          else
            cleanup_working_directory
            return unless all_components?
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