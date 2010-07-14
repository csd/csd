# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'debian')

module CSD
  module Application
    module Minisip
      class Ubuntu10 < Debian
      
        def before_compile
          super
          fix_ubuntu_10_04
        end
        
        def fix_ubuntu_10_04
          # TODO put backup file in Path.xxx
          if File.exist?("#{Path.giomm_header}.ai-backup")
            UI.warn "giomm-2.4 seems to be fixed already, I won't touch it. Delete `#{"#{Path.giomm_header}.ai-backup"}´ to enforce it."
          else
            Path.new_giomm_header = File.join(Dir.mktmpdir, 'giomm.h')
            Cmd.copy(Path.giomm_header, Path.new_giomm_header)
            Cmd.replace(Path.new_giomm_header, '#include <giomm/socket.h>', "/* ----- AI COMMENTING OUT START ----- \n#include <giomm/socket.h>")
            Cmd.replace(Path.new_giomm_header, '#include <giomm/tcpconnection.h>', "#include <giomm/tcpconnection.h>\n ----- AI COMMENTING OUT END ----- */")
            Cmd.replace(Path.new_giomm_header, '# include <giomm/unixconnection.h>', "// #include <giomm/unixconnection.h>  // COMMENTED OUT BY AI")
            Cmd.run("sudo cp #{Path.giomm_header} #{Path.giomm_header}.ai-backup")
            Cmd.run("sudo cp #{Path.new_giomm_header} #{Path.giomm_header}")
          end
        end
      
      
      end
    end
  end
end