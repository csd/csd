# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Mslog
      class Base < CSD::Application::Base
        
                DESKTOP_ENTRY = %{
[Desktop Entry]
Encoding=UTF-8
Name=MSlog Server
GenericName=A remote reveiver for MiniSIP log files
Comment=Provide a logging server for MiniSIP
Exec=PLACEHOLDER
Icon=mslog_gnome
Terminal=true
Type=Application
StartupNotify=true
Categories=Application;Internet;Network;Chat;AudioVideo}

        # A list of apt-get packages that are required to install the logging server.
        #
        DEBIAN_DEPENDENCIES = %w{ ant openjdk-6-jre openjdk-6-jdk }
        
        def install
          UI.separator
          UI.info "This operation will install the logging server of MiniSIP.".green.bold
          UI.separator
          introduction
          install!
        end
        
        def install!
          create_working_directory
          define_relative_paths
          apply
          process_logging_server
          create_desktop_entry
          update_gnome_menu_cache
          cleanup_working_directory
        end
        
        def introduction
          UI.info " Working directory:       ".green.bold + Path.work.to_s.yellow
          if Options.debug
            UI.info " Your Platform:           ".green + Gem::Platform.local.humanize.to_s.yellow
            UI.info(" Application module:      ".green + self.class.name.to_s.yellow)
          end
          UI.separator
          if Options.help
            UI.info Options.helptext
            # Cleanup in case the working directory was temporary and is empty
            Path.work.rmdir if Options.temp and Path.work.directory? and Path.work.children.empty?
            raise CSD::Error::Argument::HelpWasRequested
          else
            raise Interrupt unless Options.yes or Options.reveal or UI.continue?
          end
        end
        
        def apply
          UI.info "Update the package index".green.bold
          Cmd.run "sudo apt-get update --yes --force-yes", :announce_pwd => false
          UI.info "Installing Debian packages".green.bold
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.join(' ')} --yes --force-yes", :announce_pwd => false
        end
        
        def process_logging_server
          Cmd.git_clone 'Source code of logging server', 'git://github.com/csd/minisip-logging-server.git', Path.packages
          Cmd.cd Path.packages, :internal => true
          Cmd.run 'ant'
          Cmd.cd Path.bin, :internal => true
          Cmd.run "chmod +x #{Path.logging_server_run}", :announce_pwd => false
          Cmd.run %{echo "export JAVA_HOME=/usr" >> ~/.bashrc;. ~/.bashrc}
        end
        
        def create_desktop_entry
          UI.info "Installing Gnome menu item".green.bold
          if Cmd.download(GNOME_ICON_URL, Path.mslog_gnome_png).success?
            Cmd.run("sudo cp #{Path.mslog_gnome_png} #{Path.mslog_gnome_pixmap}", :announce_pwd => false)
            Cmd.touch_and_replace_content Path.mslog_new_desktop_entry, DESKTOP_ENTRY.sub('PLACEHOLDER', Path.logging_server_run), :internal => true
            Cmd.run "sudo mv #{Path.mslog_new_desktop_entry} #{Path.mslog_desktop_entry}", :announce_pwd => false
            Gnome.update_gnome_menu_cache
          else
            UI.warn "The menu item could not be created, because the image file could not be downloaded from #{GNOME_ICON_URL}.".green.bold
          end
        end
        
        def update_gnome_menu_cache
          return unless Gem::Platform.local.ubuntu_10?
          Cmd.run %{sudo sh -c "/usr/share/gnome-menus/update-gnome-menus-cache /usr/share/applications/ > /usr/share/applications/desktop.${LANG}.cache"}, :announce_pwd => false
        end
        
        def define_relative_paths
          Path.packages                 = Pathname.new(File.join(Path.work, 'minisip-logging-server'))
          Path.bin                      = Pathname.new(File.join(Path.packages, 'bin'))
          Path.logging_server_run       = Pathname.new(File.join(Path.bin, 'logging-server-0.1.sh'))
          Path.mslog_gnome_png          = Pathname.new(File.join(Path.packages, 'img', 'mslog_gnome.png'))
          Path.mslog_gnome_pixmap       = Pathname.new(File.join('/', 'usr', 'share', 'pixmaps', 'mslog_gnome.png'))
          Path.mslog_desktop_entry      = Pathname.new(File.join('/', 'usr', 'share', 'applications', 'mslog.desktop'))
          Path.mslog_new_desktop_entry  = Pathname.new(File.join(Path.work, 'mslog.desktop'))
        end
        
      end
    end
  end
end