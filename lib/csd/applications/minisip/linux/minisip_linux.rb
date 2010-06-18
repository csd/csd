require File.relative(__FILE__, '..', 'minisip')

module CSD
  module Application
    module Minisip
      class MinisipLinux < Minisip
        
        DEBIAN_DEPENDENCIES = ['libssl-dev', 'libglademm-2.4-dev', 'libsdl-dev', 'git-core', 'subversion', 'automake', 'libtool', 'libltdl3-dev', 'build-essential', 'libavcodec-dev', 'libswscale-dev', 'nasm', 'libasound2-dev', 'libsdl-ttf2.0-dev']
        
        def before_build
          fix_aclocal_dirlist
          install_aptitude_dependencies
        end
        
        def after_build
          ldconfig_and_gtkgui
        end

        def install_aptitude_dependencies
          DEBIAN_DEPENDENCIES.each do |apt|
            run_command("sudo apt-get --yes install #{apt}")
          end if options.apt_get
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
          run_command("ldconfig /usr/local/lib/libminisip.so.0")
          run_command("minisip_gtkgui")
        end
        
      end
    end
  end
end