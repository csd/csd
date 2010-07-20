# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix/linux'

module CSD
  module Application
    module Minisip
      class Debian < Linux
        
        # A list of apt-get packages that are required by this application. 
        #
        DEBIAN_DEPENDENCIES = %w{ libxv-dev libssl-dev libgtkmm-2.4-dev libglademm-2.4-dev libsdl-dev git-core subversion automake libtool libltdl3-dev build-essential libavcodec-dev libswscale-dev libasound2-dev libsdl-ttf2.0-dev nasm yasm ffmpeg }
        
        def compile!
          install_aptitude_dependencies if Options.apt_get
          super
        end
        
        def package!
          modify_libminisip_rules
          super
        end
        
        def install_aptitude_dependencies
          Cmd.run("sudo apt-get update")
          DEBIAN_DEPENDENCIES.each do |apt|
            Cmd.run("sudo apt-get install #{apt} --yes --fix-missing")
          end
        end
        
        def modify_libminisip_rules
          if File.exist? Path.repository_libminisip_rules_backup
            UI.warn "The libminisip rules seem to be fixed already, I won't touch them now. Delete #{Path.repository_libminisip_rules_backup.enquote} to enforce it."
          else
            Cmd.copy Path.repository_libminisip_rules, Path.repository_libminisip_rules_backup
            Cmd.replace Path.repository_libminisip_rules, 'AUTOMATED_INSTALLER_PLACEHOLDER=""', [cpp_flags, ld_flags].join(' ')
          end
        end
        
      end
    end
  end
end