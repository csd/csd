# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix/linux'

module CSD
  module Application
    module Minisip
      class Debian < Linux
        
        # A list of apt-get packages that are required to compile minisip including hdviper and ffmpeg
        #
        DEBIAN_DEPENDENCIES = %w{ automake build-essential checkinstall git-core libnotify-bin libasound2-dev libavcodec-dev libglademm-2.4-dev libgtkmm-2.4-dev libltdl3-dev libsdl-dev libsdl-ttf2.0-dev libssl-dev libtool libswscale-dev libx11-dev libxv-dev nasm subversion yasm }

        def compile!
          aptitude
          after_aptitude
          super
        end
        
        def after_aptitude
        end
        
        def package!
          create_working_directory
          Core.modify_libminisip_rules # TODO: Oursource into Component::Core
          super
        end
        
        def aptitude
          return unless Options.apt_get
          UI.info "Installing Debian dependencies for MiniSIP".green.bold
          Cmd.run 'sudo apt-get update', :announce_pwd => false
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.sort.join(' ')} --yes --fix-missing", :announce_pwd => false
          UI.info "Installing 2D/3D acceleration for ATI graphic cards".green.bold
          # Note that aptitude will not fail if the package cannot be found. This is very useful, because fglrx does not
          # exist on Ubuntu 9.10, yet this command will not fail. Apt-get install would fail.
          Cmd.run "sudo aptitude install fglrx", :announce_pwd => false, :die_on_failure => false
        end
        
      end
    end
  end
end