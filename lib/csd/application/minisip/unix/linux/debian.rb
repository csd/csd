# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix/linux'

module CSD
  module Application
    module Minisip
      class Debian < Linux
        
        # A list of apt-get packages that are required by this application. 
        #
        DEBIAN_DEPENDENCIES = %w{ libssl-dev libgtkmm-2.4-dev libglademm-2.4-dev libsdl-dev git-core subversion automake libtool libltdl3-dev build-essential libavcodec-dev libswscale-dev libasound2-dev libsdl-ttf2.0-dev nasm yasm ffmpeg }
        
        def compile!
          install_aptitude_dependencies if Options.apt_get
          super
          run_minisip_gtk_gui
        end
        
        def install_aptitude_dependencies
          Cmd.run("sudo apt-get update")
          DEBIAN_DEPENDENCIES.each do |apt|
            Cmd.run("sudo apt-get install #{apt} --yes --fix-missing")
          end
        end
        
        def modify_libminisip_rules
          Cmd.replace(Path.repository_libminisip_rules, 'AUTOMATED_INSTALLER_PLACEHOLDER=""', [cpp_flags, ld_flags].join(' '))
        end
        
        def run_minisip_gtk_gui
          Cmd.run(Path.build_gtkgui)
        end
        
      end
    end
  end
end