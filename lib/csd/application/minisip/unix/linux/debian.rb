# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix/linux'

module CSD
  module Application
    module Minisip
      class Debian < Linux
        
        # A list of apt-get packages that are required to compile minisip including hdviper and ffmpeg
        #
        DEBIAN_DEPENDENCIES = %w{ automake build-essential checkinstall git-core libasound2-dev libavcodec-dev libglademm-2.4-dev libgtkmm-2.4-dev libltdl3-dev libnotify-bin libsdl-dev libsdl-ttf2.0-dev libssl-dev libswscale-dev libtool libx11-dev libxv-dev nasm subversion yasm }

        def compile!
          aptitude
          after_aptitude
          super
        end
        
        def check
          Core.ensure_ati_vsync
          Core.update_decklink_firmware
          load_decklink_on_runtime
        end
        
        def load_decklink_on_runtime
          UI.info "Loading Decklink drivers in case they were not loaded already".green.bold
          Cmd.run "sudo /sbin/modprobe blackmagic", :announce_pwd => false, :die_on_failure => false
        end
        
        def after_aptitude
        end
        
        def package!
          create_working_directory
          super
        end
        
        def aptitude
          return unless Options.apt_get
          UI.info "Installing Debian dependencies for MiniSIP".green.bold
          Cmd.run 'sudo apt-get update', :announce_pwd => false
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.sort.join(' ')} --yes --fix-missing", :announce_pwd => false
          # For some reason OpenGL crashes if we try to use this packet.
          # return unless Gem::Platform.local.ubuntu_10? or Options.reveal
          # UI.info "Installing 2D/3D acceleration for ATI graphic cards".green.bold
          # Note that aptitude will not fail if the package cannot be found. This is very useful, because fglrx does not
          # exist on Ubuntu 9.10, yet this command will not fail. Apt-get install would fail.
          # Cmd.run "sudo aptitude install fglrx -y", :announce_pwd => false, :die_on_failure => false
        end
        
      end
    end
  end
end