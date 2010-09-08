# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Mslog
      class Base < CSD::Application::Base

        # Necessary contents for MSLog .desktop file. It will be used in the method of create_desktop_entry.
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
        DEBIAN_DEPENDENCIES = %w{ ant openjdk-6-jre openjdk-6-jdk libnotify-bin }
        
        # The method is to notify users about following operation of AI, and initiate introduction method.
        # The actual installation process is carried out by method install! for the purpose of keeping source code clean.
        #
        def install
          UI.separator
          UI.info "This operation will install the logging server of MiniSIP.".green.bold
          UI.separator
          introduction
          install!
        end
        
        # The method is to set up logging server by initiate corresponding method. Its major operation includes
        # install library dependencies, download and install logging server, create a desktop entry for logging server.
        # Thus users can start the logging server by simply clicking the MSLog button in the Applications menu.
        #
        def install!
          create_working_directory
          define_relative_paths
          apt_get
          download
          process
          create_desktop_entry
          send_notification
          congratulations
        end
        
        # This method is to provide general introductions to users, like current working directory.
        # 
        # ====Options
        # [debug]  If debug option is set, users will be notified about system platform and current working module.
        # [help]   If help option is set, AI will provide all help information and cleanup.
        # [reveal] If reveal option is set, AI will continue and process the next method.
        # [yes]    If yes option is set, AI will continue and process the next method.
        # 
        # If users did not specify any option, AI will ask for their willingness to continue and process the next method 
        # after the users choose 'yes'. Or AI will terminate its operation.
        # 
        # ====Notes
        # In mslog module the options of temp and work_dir will be turned off by default. The reason of doing that is because
        # the minisip-logging-server directory and its content is needed to run the logging server. Thus AI is not going to 
        # use temp directory to process the source code or clean up the working directory after installation procedure.
        # 
        def introduction
          UI.info " Working directory:       ".green.bold + Path.work.to_s.yellow
          if Options.debug
            UI.info " Your Platform:           ".green + Gem::Platform.local.humanize.to_s.yellow
            UI.info(" Application module:      ".green + self.class.name.to_s.yellow)
          end
          UI.separator
          if Options.help
            UI.info Options.helptext
            raise CSD::Error::Argument::HelpWasRequested
          else
            raise Interrupt unless Options.yes or Options.reveal or UI.continue?
          end
        end
        
        #
        #
        def apt_get
          UI.info "Updating the package index".green.bold
          Cmd.run "sudo apt-get update --yes --force-yes", :announce_pwd => false
          UI.info "Installing Debian packages".green.bold
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.join(' ')} --yes --force-yes", :announce_pwd => false
        end

        def download
          Cmd.git_clone 'Source code of logging server', 'git://github.com/csd/minisip-logging-server.git', Path.packages
        end
        
        def process
          Cmd.cd Path.packages, :internal => true
          Cmd.run %{echo "export JAVA_HOME=/usr" >> ~/.bashrc} unless File.read(Path.bashrc) =~ /JAVA_HOME/
          # For some reason the bashrc file cannot be reloaded systemwide from within the AI.
          # As a workaround we devine the JAVA_HOME constant manually instead of using the '.'-command
          # Cmd.run ". ~/.bashrc"
          ENV['JAVA_HOME'] = '/usr'
          # Compiling the Java source code
          Cmd.run 'ant'
          # Giving execution permissions to the executable
          Cmd.run "chmod +x #{Path.logging_server_run}", :announce_pwd => false
        end
        
        def create_desktop_entry
          UI.info "Installing Gnome menu item".green.bold
          Cmd.run("sudo cp #{Path.mslog_gnome_png} #{Path.mslog_gnome_pixmap}", :announce_pwd => false)
          Cmd.touch_and_replace_content Path.mslog_new_desktop_entry, DESKTOP_ENTRY.sub('PLACEHOLDER', Path.logging_server_run), :internal => true
          Cmd.run "sudo mv #{Path.mslog_new_desktop_entry} #{Path.mslog_desktop_entry}", :announce_pwd => false
          update_gnome_menu_cache
        end
        
        def update_gnome_menu_cache
          return unless Gem::Platform.local.ubuntu_10?
          Cmd.run %{sudo sh -c "/usr/share/gnome-menus/update-gnome-menus-cache /usr/share/applications/ > /usr/share/applications/desktop.${LANG}.cache"}, :announce_pwd => false
          Cmd.run "sudo chown root:root #{Path.mslog_desktop_entry}", :announce_pwd => false
        end
        
        def send_notification
          Cmd.run %{notify-send --icon=mslog_gnome "MiniSIP Logging Server installation complete" "You are now ready to use your logging server." }, :internal => true, :die_on_failure => false
        end
        
        def congratulations
          UI.separator
          UI.info "        MiniSIP Logging Server installation complete.".green.bold
          UI.info "  Please have a look in your applications menu -> Internet."
          UI.separator
        end
        
        def define_relative_paths
          Path.packages                 = Pathname.new(File.join(Path.work, 'minisip-logging-server'))
          Path.bin                      = Pathname.new(File.join(Path.packages, 'bin'))
          Path.logging_server_run       = Pathname.new(File.join(Path.bin, 'logging-server-0.1.sh'))
          Path.mslog_gnome_png          = Pathname.new(File.join(Path.packages, 'img', 'mslog_gnome.png'))
          Path.mslog_gnome_pixmap       = Pathname.new(File.join('/', 'usr', 'share', 'pixmaps', 'mslog_gnome.png'))
          Path.mslog_desktop_entry      = Pathname.new(File.join('/', 'usr', 'share', 'applications', 'mslog.desktop'))
          Path.mslog_new_desktop_entry  = Pathname.new(File.join(Path.work, 'mslog.desktop'))
          Path.bashrc                   = Pathname.new(File.join(ENV['HOME'], '.bashrc'))
        end
        
      end
    end
  end
end