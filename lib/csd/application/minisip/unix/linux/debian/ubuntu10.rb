# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix/linux/debian'

module CSD
  module Application
    module Minisip
      class Ubuntu10 < Debian
        
        def after_aptitude
          fix_ubuntu_10_04
          super
        end
        
        def fix_ubuntu_10_04
          UI.info "Fixing broken Debian libraries (Ubuntu 10.04 only)".green.bold
          if Path.giomm_header_backup.file? and !Options.reveal
            UI.warn "giomm-2.4 seems to be fixed already, I won't touch it now. Delete #{Path.giomm_header_backup.enquote} to enforce it."
          else
            Path.new_giomm_header = File.join(Path.work, 'giomm.h')
            Cmd.copy(Path.giomm_header, Path.new_giomm_header)
            Cmd.replace Path.new_giomm_header do |r|
              r.replace '#include <giomm/socket.h>', "/* ----- AI COMMENTING OUT START ----- \n#include <giomm/socket.h>"
              r.replace '#include <giomm/tcpconnection.h>', "#include <giomm/tcpconnection.h>\n ----- AI COMMENTING OUT END ----- */"
            end
            # We cannot use Cmd.copy here, because Cmd.copy has no superuser privileges.
            # And since we are for sure on Ubuntu, these commands will work.
            Cmd.run("sudo cp #{Path.giomm_header} #{Path.giomm_header_backup}")
            Cmd.run("sudo cp #{Path.new_giomm_header} #{Path.giomm_header}")
          end
        end
        
      end
    end
  end
end