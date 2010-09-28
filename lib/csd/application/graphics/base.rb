# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Graphics
      class Base < CSD::Application::Base
        
        # This method will notify users about following operations and initiate installation process.
        # The reason of creating another method to carry out actual installation process is to keep the
        # source code clean and easy to read.
        #
        def install
          UI.separator
          UI.info "This operation will download and install the latest graphics card drivers.".green.bold
          UI.separator
          introduction
          install!
        end
        
        # This method is to create a working directory to preserve graphical card installation scripts,
        # initiate graphics card installation GUI and
        # clean up the working directory when the graphical card driver has been successfully installed.
        #
        def install!
          define_relative_paths
          create_working_directory
          aptitude
          process_graphics_card
          cleanup_working_directory
        end
        
        def aptitude
          UI.info "Installing Debian dependencies".green.bold
          Cmd.run 'sudo apt-get update', :announce_pwd => false
          Cmd.run "sudo apt-get install git-core --yes --fix-missing", :announce_pwd => false
        end
        
        # This method is to provide general introductions to users, like current working directory.
        # 
        # ====Options
        # [debug]  If debug option is set, users will be notified about system platform and current working module.
        # [help]   If help option is set, AI will provide all help information and cleanup in case the working directory was temporary and is empty.
        # [reveal] If reveal option is set, AI will continue and process the next method.
        # [yes]    If yes option is set, AI will continue and process the next method.
        # 
        # If users did not specify any option, AI will ask for their willingness to continue and process the next method 
        # after the users choose 'yes'. Or AI will terminate its operation.
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
            # Cleanup in case the working directory was temporary and is empty
            Path.work.rmdir if Options.temp and Path.work.directory? and Path.work.children.empty?
            raise CSD::Error::Argument::HelpWasRequested
          else
            raise Interrupt unless Options.yes or Options.reveal or UI.continue?
          end
        end
        
        # This method will determine the model of graphics card and initiate corresponding installation process
        # Currently, only Radeon and GeForce graphics cards are supported.
        #
        def process_graphics_card
          case determine_graphic_card
            when /Radeon/
              install_radeon
            when /GeForce/
              install_geforce
            else
              raise Error::Graphics::CardNotSupported, "Sorry, currently only ATI Radeon and nVIDIA GeForce are supported"
          end
        end
        
        # The method is to detect graphics card model
        #
        # ====Returns
        # * It will return 'Radeon',when options of force_radeon is set.
        # * It will return 'Radeon',when options of force_radeon is set.
        # * Otherwise, it will return the result of graphics card checking command.
        # ====Purpose
        # This methold is supposed to detect the current graphics card models and initiate corresponding
        # installation process. However, whenever a user want to force its system to install another graphics
        # card driver, it will fake the detection result and comply with users' request.
        #
        def determine_graphic_card
          return 'Radeon' if Options.force_radeon
          return 'GeForce' if Options.force_geforce
          Cmd.run('lspci | grep VGA', :internal => true).output
        end
        
        # The method is to check out ATI radeon driver from git repository and execute the shell script.
        #
        # * It will allow the script to be run as a program, Because  Linux system will not grant this permission to shell script for security reason.
        # * The method will ask for users' approval before initiate the shell script.
        #
        def install_radeon
          Cmd.git_clone 'drivers for ATI radeon', 'http://github.com/csd/ati.git', Path.radeon
          Cmd.run "chmod +x #{Path.radeon_run}", :announce_pwd => false
          proprietary_continue
          Cmd.run "sudo #{Path.radeon_run}", :announce_pwd => false
        end
        
        # The method is to check installation environment and initiate installation method of GeForce.
        # The installation process of GeForce driver need to update users' X configuration, so AI is suppose to
        # turn off X server before initiating the installation procedure of GeForce driver.
        # ==== X server status
        #
        # [X server is running] AI will terminate X server, but this operation will also stop GNOME and AI itself. In order to continue with the installation procedure, users will start AI again from CLI.
        # [X server has be turned off] AI will initiate the installation process, but whenever there is an error occur, AI will restart GNOME mode and clean up the working directory.
        #
        def install_geforce
          if xserver_running? or Options.reveal
            UI.separator
            UI.info 'This operation cannot be performed in the GNOME environment.'.red.bold
            UI.info 'The AI can stop GNOME for you now. Once this happens, you need'.green.bold
            UI.info 'to provide your Linux credentials and start the AI again from there.'.green.bold
            UI.separator
            if Options.yes or Options.reveal or UI.continue?
              Cmd.run "sudo /etc/init.d/gdm stop", :announce_pwd => false
              raise Error::Graphics::XServerStillRunning
            else
              raise Interrupt
            end
          else
            Cmd.run "sudo /etc/init.d/gdm start" unless install_geforce!
            cleanup_working_directory
          end
        end
        
        # The method is to check X server status.
        # ====Returns
        # * +true+ if X server is running
        # * +false+ if X server is not running
        #
        def xserver_running?
          result = Cmd.run('ps -ef', :internal => true)
          result.success? and (result.output =~ /bin\/X.+gdm/ or result.output =~ /xinit/)
        end
        
        # The method is to check out GeForce installation script for git repository and initiate installation GUI.
        # Currently, MiniSIP is only run on x86 systems, and GeForce driver installation is to improve the video quality
        # of MiniSIP. Thus, before checking out GeForce installation script, AI will check the architecture of system.
        # When it is a 64-bit system, AI will raise an error and terminate the process. While the system has a x86 architecture,
        # AI will continue with the installation process. AI will check out the installation script from git repositoy, 
        # and permit the script to run as a program.
        # AI will ask for users' approval before initiate the shell script.
        # ==== Notes
        # we do not use Cmd.run to initiate the installation process, because the User input is not forwared to
        # the executed application correctly. We will use Ruby's native command execution:
        #  system "sudo #{Path.geforce_run}"
        # instead of 
        #  Cmd.run "sudo #{Path.geforce_run}", :announce_pwd => false, :verbose => true, :die_on_failure => false
        #
        def install_geforce!
          raise Error::Graphics::Amd64NotSupported, "Sorry, nVIDIA GeForce is currently only supported on x86" unless Gem::Platform.local.cpu == 'x86' 
          Cmd.git_clone 'drivers for nVIDIA GeForce', 'http://github.com/csd/nvidia.git', Path.geforce
          Cmd.run "chmod +x #{Path.geforce_run}", :announce_pwd => false
          proprietary_continue_for_geforce
          # Note that we cannot use Cmd.run here, because the User input is not forwared to
          # the executed application correctly. We will use Ruby's native command execution
          # Cmd.run "sudo #{Path.geforce_run}", :announce_pwd => false, :verbose => true, :die_on_failure => false
          system "sudo #{Path.geforce_run}"
        end
        
        # The method is to notify the user about following operation of AI and initiate the method of wait_for_confirmation,
        # where users can choose to continue with the operation or not.
        #
        def proprietary_continue
          UI.separator
          UI.info 'The proprietary installer for your graphic card will now be executed.'.green.bold
          UI.info 'Please follow the instructions manually.'.green.bold
          UI.separator
          wait_for_confirmation
        end
        
        # The method is to provide necessary tips for users to install GeForce. Because users need to allow GeForce to 
        # update X configuration in the installation wizard and restart the system to make all changes take effect.
        # The method will also initiate the method of wait_for_confirmation, where users can choose to continue with the operation or not.
        #
        def proprietary_continue_for_geforce
          UI.separator
          UI.info 'The proprietary installer for your graphic card will now be executed.'.green.bold
          UI.info 'Be sure to select "Yes" when asked if nvidia-xconfig should update your X configuration.'.green.bold
          UI.info 'Please restart your computer after exiting the wizard.'.green.bold
          UI.separator
          wait_for_confirmation
        end
        
        # This method is to ask users about their willingness to continue. If the user choose to continue or AI is running
        # in reveal mode, AI will continue with its operation. Or AI will clear up the working directory and terminate the process.
        #
        def wait_for_confirmation
           unless UI.continue? or Options.reveal
           cleanup_working_directory
           raise Interrupt
          end
        end
        
        #This method is to define relative path in graphics module. This will make the program clean and easy to read.
        #
        def define_relative_paths
          UI.debug "#{self.class}#define_relative_paths defines relative graphics paths now"
          Path.radeon       = Pathname.new(File.join(Path.work, 'radeon'))
          Path.radeon_run   = Pathname.new(File.join(Path.radeon, 'ati-driver-installer-10-9-x86.x86_64.run'))
          Path.geforce      = Pathname.new(File.join(Path.work, 'geforce'))
          Path.geforce_run  = Pathname.new(File.join(Path.geforce, 'NVIDIA-Linux-x86-256.44.run.sh'))
        end
        
      end
    end
  end
end
