require File.join(File.dirname(__FILE__), '..', 'minisip')

module CSD
  module Application
    module Minisip
      class MinisipLinux < Minisip
        
        def build!
          define_paths
          create_working_dir
          install_aptitude_dependencies
          checkout_repository
          make_libraries
          fix_aclocal_dirlist
          ldconfig_and_gtkgui
        end
        
        def install_aptitude_dependencies
          ['git-core', 'subversion', 'automake', 'libssl-dev', 'libtool', 'libglademm-2.4-dev'].each do |apt|
            run_command("sudo apt-get --yes install #{apt}")
          end
        end
        
        def fix_aclocal_dirlist
          run_command "sudo echo /usr/local/share/aclocal >> /usr/share/aclocal/dirlist"
        end

        def ldconfig_and_gtkgui
          run_command("ldconfig /usr/local/lib/libminisip.so.0")
          run_command("minisip_gtkgui")
        end
        
      end
    end
  end
end