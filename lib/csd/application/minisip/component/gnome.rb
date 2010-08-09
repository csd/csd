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
Name=MiniSIP Client
GenericName=Video conferencing client
Comment=Have a video conference in high-definition
Exec=minisip_gtkgui
Icon=minisip_gnome
Terminal=false
Type=Application
StartupNotify=true
Categories=Application;Internet;Network;Chat;AudioVideo}
            
            def compile
              UI.debug "#{self}.compile was called"
              return unless Gem::Platform.local.debian? # TODO: Actually, Ubuntu only, not Debian. But I'm not so sure.
              if Options.this_user
                # This command opens the bin directory in Debian/Ubuntu as to show where the executables are located in a single-user mode installation.
                UI.info "Revealing user-specific MiniSIP exectutables"
                Cmd.run "nautilus #{Path.build_bin}"
              else
                create_desktop_entry
                update_gnome_menu_cache
              end
              send_notification
            end
            
            def create_desktop_entry
              # In fact, we would like to update the desktop entry it each time the AI (re-)compiles minisip
              # So we do not return here now
              # return if Path.minisip_gnome_pixmap.file? and Path.minisip_desktop_entry.file?
              UI.info "Installing Gnome menu item".green.bold
              Cmd.run("sudo cp #{Path.minisip_gnome_png} #{Path.minisip_gnome_pixmap}", :announce_pwd => false)
              Path.new_desktop_entry = Pathname.new File.join(Path.work, 'minisip.desktop')
              Cmd.touch_and_replace_content Path.new_desktop_entry, DESKTOP_ENTRY, :internal => true
              Cmd.run "sudo mv #{Path.new_desktop_entry} #{Path.minisip_desktop_entry}", :announce_pwd => false
            end
            
            # Every desktop entry file not created via dpkg will not update the gnome menus cache. We need to
            # do this manually here. See https://bugs.launchpad.net/ubuntu/+source/gnome-menus/+bug/581838
            #
            def update_gnome_menu_cache
              Cmd.run %{sudo sh -c "/usr/share/gnome-menus/update-gnome-menus-cache /usr/share/applications/ > /usr/share/applications/desktop.${LANG}.cache"}
            end
            
            # Sends an OSD notification.
            #
            def send_notification
              Cmd.run %{notify-send --icon=minisip_gnome "MiniSIP installation complete" "Please have a look in your Applications menu -> Internet." }, :internal => true, :die_on_failure => false
            end
          
          end
        end
      end
    end
  end
end
