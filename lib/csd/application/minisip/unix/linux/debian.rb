# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'linux')

module CSD
  module Application
    module Minisip
      class Debian < Linux
        
        # A list of apt-get packages that are required by this application. 
        #
        DEBIAN_DEPENDENCIES = %w{ libssl-dev libgtkmm-2.4-dev libglademm-2.4-dev libsdl-dev git-core subversion automake libtool libltdl3-dev build-essential libavcodec-dev libswscale-dev libasound2-dev libsdl-ttf2.0-dev nasm yasm ffmpeg }
        
        def before_compile
          #fix_aclocal_dirlist
          install_aptitude_dependencies if Options.apt_get
        end
        
        def after_compile
          ldconfig_and_gtkgui
        end
        
        def install_aptitude_dependencies
          Cmd.run("sudo apt-get update")
          DEBIAN_DEPENDENCIES.each do |apt|
            Cmd.run("sudo apt-get install #{apt} --yes --fix-missing")
          end
        end
        
        def fix_aclocal_dirlist
          return
          content = '/usr/local/share/aclocal'
          target = Pathname.new('/usr/share/aclocal/dirlist')
          unless target.exist? and File.new(target).read == content # TODO: replace with File.read
            begin
              File.new(target, 'w').write(content).close              
            rescue Errno::EACCES => e
              say "Please run the following commands with the right permissions.".red.bold
              say "  sudo rm /usr/share/aclocal/dirlist".green.bold
              say "  sudo touch /usr/share/aclocal/dirlist".green.bold
              say "  sudo echo /usr/local/share/aclocal >> /usr/share/aclocal/dirlist".green.bold
              exit
            end
          end
        end
        
        def ldconfig_and_gtkgui
          Cmd.run(Path.build_gtkgui)
        end
        
      end
    end
  end
end