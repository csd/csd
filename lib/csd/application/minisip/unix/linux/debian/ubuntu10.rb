# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix/linux/debian'

module CSD
  module Application
    module Minisip
      class Ubuntu10 < Debian
        
        def compile!
          fix_ubuntu_10_04
          exit if Options.only_fix_giomm
          super
        end
        
        def fix_ubuntu_10_04
          if File.exist?("#{Path.giomm_header}.ai-backup")
            UI.warn "giomm-2.4 seems to be fixed already, I won't touch it now. Delete `#{"#{Path.giomm_header}.ai-backup"}´ to enforce it."
          else
            Path.new_giomm_header = File.join(Dir.mktmpdir, 'giomm.h')
            Cmd.copy(Path.giomm_header, Path.new_giomm_header)
            Cmd.replace Path.new_giomm_header do |r|
              r.replace '#include <giomm/socket.h>', "/* ----- AI COMMENTING OUT START ----- \n#include <giomm/socket.h>"
              r.replace '#include <giomm/tcpconnection.h>', "#include <giomm/tcpconnection.h>\n ----- AI COMMENTING OUT END ----- */"
            end
            Cmd.run("sudo cp #{Path.giomm_header} #{Path.giomm_header}.ai-backup")
            Cmd.run("sudo cp #{Path.new_giomm_header} #{Path.giomm_header}")
          end
        end
      
      end
    end
  end
end