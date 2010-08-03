# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Gnome
          class << self
            
            DESKTOP_ENTRY = %{
[Desktop Entry]
Encoding=UTF-8
Name=MiniSIP
GenericName=Video conferencing client
Comment=Your open-source, high-definition video conferencing client.
Exec=minisip_gtkgui
Icon=accessories-calculator
Terminal=false
Type=Application
StartupNotify=true
Categories=GNOME;GTK;Utility;Calculator}
            
            def compile
              UI.debug "#{self}.compile was called"
              Cmd.run "nautilus #{Path.build_bin}" if Gem::Platform.local.debian? and Options.this_user
              
            end
          
          end
        end
      end
    end
  end
end
