# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    # This module sets up MiniSIP logging server in the system.
    #
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
        
        # This method notifies users about following operation of AI, and initiates introduction method.
        # The actual installation process is carried out by method install! for the purpose of keeping source code clean.
        #
        def install
          UI.separator
          UI.info "This operation will install the logging server of MiniSIP.".green.bold
          UI.separator
          introduction
          install!
        end
        
        # This method sets up logging server by initiate corresponding method. Its major operation includes
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
        
        # This method provides general introductions to users, like current working directory.
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
        
        # This method installs all library dependencies of MiniSIP logging server.
        # It will first update the package index and then install all Debian dependencies.
        # AI will force both of the operations continue without being interrupted by the request for user's approval
        # This is because users have been asked once about their willingness to continue in the introduction method,
        # thus AI will not bother users again for each of the library dependency.
        #
        def apt_get
          UI.info "Updating the package index".green.bold
          Cmd.run "sudo apt-get update --yes --force-yes", :announce_pwd => false
          UI.info "Installing Debian packages".green.bold
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.join(' ')} --yes --force-yes", :announce_pwd => false
        end
        
        # The method is to check out MiniSIP source code from git repository and place it into the current working directory.
        #
        def download
          Cmd.git_clone 'Source code of logging server', 'http://github.com/csd/minisip-logging-server.git', Path.packages
        end
        
        # This method compiles Java source code.
        # It will set the constant JAVA_HOME to the value of '/usr', since Java is required when running logging server.
        # It will also write the constant into bashrc file, so the constant will be set every time when the system boot up.
        # However, the bashrc file cannot be reloaded systemwide from within the AI.
        # As a workaround we derive the JAVA_HOME constant manually by the command
        #  ENV['JAVA_HOME'] = '/usr'
        # instead of using the '.'-command
        #  Cmd.run ". ~/.bashrc"
        # Then, AI will compile the Java source code by +ant+ command and give execution permissions to logging server shell scripts.
        # AI will not execute the executable. User can start the logging server by clicking MSLog icon in the Applications menu.
        #
        def process
          Cmd.cd Path.packages, :internal => true
          Cmd.run %{echo "export JAVA_HOME=/usr" >> ~/.bashrc} unless File.read(Path.bashrc) =~ /JAVA_HOME/
          # For some reason the bashrc file cannot be reloaded systemwide from within the AI.
          # As a workaround we derive the JAVA_HOME constant manually instead of using the '.'-command
          # Cmd.run ". ~/.bashrc"
          ENV['JAVA_HOME'] = '/usr'
          # Compiling the Java source code
          Cmd.run 'ant'
          # Giving execution permissions to the executable
          Cmd.run "chmod +x #{Path.logging_server_run}", :announce_pwd => false
        end
        
        # This method creates desktop entry, so users can run logging server by clicking the MSLog icon in the Applications menu.
        # It copies the downloaded icon to pixmaps directory, so the icon can be shown at the gnome menu. 
        # It creates a .desktop file, fulfills the file with the constant DESKTOP_ENTRY, and substitutes the PLACEHOLDER with execution commands. 
        # Then, AI copies the .desktop file to /usr/share/applications directory and initiates the method of update_gnome_menu_cache to make all the
        # modifications take effect.
        #
        def create_desktop_entry
          UI.info "Installing Gnome menu item".green.bold
          Cmd.run("sudo cp #{Path.mslog_gnome_png} #{Path.mslog_gnome_pixmap}", :announce_pwd => false)
          Cmd.touch_and_replace_content Path.mslog_new_desktop_entry, DESKTOP_ENTRY.sub('PLACEHOLDER', Path.logging_server_run), :internal => true
          Cmd.run "sudo mv #{Path.mslog_new_desktop_entry} #{Path.mslog_desktop_entry}", :announce_pwd => false
          update_gnome_menu_cache
        end
        
        # This method updates gnome menu cache. It first updates the gnome menus cash, so the icon can be shown
        # in the menu bar. It then gives the MSLog .desktop file a root privilege for security reasons.
        # 
        def update_gnome_menu_cache
          return unless Gem::Platform.local.ubuntu_10?
          Cmd.run %{sudo sh -c "/usr/share/gnome-menus/update-gnome-menus-cache /usr/share/applications/ > /usr/share/applications/desktop.${LANG}.cache"}, :announce_pwd => false
          Cmd.run "sudo chown root:root #{Path.mslog_desktop_entry}", :announce_pwd => false
        end
        
        # This method notifies users that MiniSIP Logging Server installation process is completed successfully.
        # This notification will be shown on the top right of the desktop in Ubuntu system.
        # Users can then start MiniSIP Logging Server by clicking the icon in gnome menu.
        #
        def send_notification
          Cmd.run %{notify-send --icon=mslog_gnome "MiniSIP Logging Server installation complete" "You are now ready to use your logging server." }, :internal => true, :die_on_failure => false
        end
        
        # This method notifies users that MiniSIP Logging Server installation process is completed successfully.
        # It is AI's internal notification, which will be shown on the command line interface.
        # Users can then start MiniSIP Logging Server by clicking the icon in gnome menu.
        # 
        def congratulations
          UI.separator
          UI.info "        MiniSIP Logging Server installation complete.".green.bold
          UI.info "  Please have a look in your applications menu -> Internet."
          UI.separator
        end
        
        # This method is to define relative path in mslog module. This will make the program clean and easy to read.
        # ====Notes
        # In the Path.bashrc constant, we use ENV['HOME'] to locate the bashrc file, because the '~/.bashrc' representation
        # can only be accepted by Linux system, while Ruby considers it as an invalid path representation.
        # 
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