# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix/linux'

module CSD
  module Application
    module Minisip
      class Debian < Linux
        
        # A list of apt-get packages that are required to compile minisip including hdviper and ffmpeg
        #
        DEBIAN_DEPENDENCIES = %w{ automake build-essential checkinstall git-core libasound2-dev libavcodec-dev libglademm-2.4-dev libgtkmm-2.4-dev libltdl3-dev libsdl-dev libsdl-ttf2.0-dev libssl-dev libswscale-dev libtool libx11-dev libxv-dev nasm subversion yasm }

        def compile!
          install_aptitude_dependencies if Options.apt_get
          after_aptitude_dependencies
          super
        end
        
        def after_aptitude_dependencies
        end
        
        def package!
          modify_libminisip_rules
          super
        end
        
        def install_aptitude_dependencies
          Cmd.run("sudo apt-get update")
          #DEBIAN_DEPENDENCIES.each do |apt|
          #  Cmd.run("sudo apt-get install #{apt} --yes --fix-missing")
          #end
          # We could also do all in one command:
          Cmd.run("sudo apt-get install #{DEBIAN_DEPENDENCIES.join(' ')} --yes --fix-missing")
        end
        
        def modify_libminisip_rules
          if File.exist? Path.repository_libminisip_rules_backup
            UI.warn "The libminisip rules seem to be fixed already, I won't touch them now. Delete #{Path.repository_libminisip_rules_backup.enquote} to enforce it."
          else
            Cmd.copy Path.repository_libminisip_rules, Path.repository_libminisip_rules_backup
            Cmd.replace Path.repository_libminisip_rules, 'AUTOMATED_INSTALLER_PLACEHOLDER=""', [minisip_cpp_flags, minisip_ld_flags].join(' ')
          end
        end
        
      end
    end
  end
end