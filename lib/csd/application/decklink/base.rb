# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Decklink
      class Base < CSD::Application::Base
        
        # A list of apt-get packages that are required to install the decklink drivers.
        #
        DEBIAN_DEPENDENCIES = %w{ libnotify-bin libmng1 dkms }
        
        # This method notifies users about following operation of AI, and initiates introduction method.
        # The actual installation process is carried out by method install! for the purpose of keeping source code clean.
        #
        def install
          UI.separator
          UI.info "This operation will download and install the DeckLink device drivers.".green.bold
          UI.separator
          introduction
          install!
        end
        
        # This method installs DeckLink drivers by initiating corresponding method sequentially. It will download DeckLink
        # drivers from official website, extract the dirver from tar file, select the suitable driver according to system 
        # architecture, and intall the DeckLink driver. After the installation process, it will add the driver into boot loader,
        # so the driver can be loaded automatically at system booting up. It will also notify the user and clean up working 
        # directory when the whole operation is completed.
        #
        def install!
          create_working_directory
          define_relative_paths
          download
          extract
          apply
          add_boot_loader
          send_notification
          cleanup_working_directory
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
        
        # This method downloads DeckLink driver from official BlackmagicDesign website. Before downloading the driver,
        # AI will search the current working directory for the driver, if it is already there, AI will not download the
        # driver again. Otherwise, AI will download the driver, and place it in the current working directory.
        #
        def download
          if Path.tar.file?
            UI.warn "The driver will not be downloaded, because it already exists: #{Path.tar.enquote}"
          else
            UI.info "Downloading DeckLink drivers from Blackmagic Design".green.bold
            Cmd.cd Path.work, :internal => true
            Cmd.run "wget #{Path.decklink_url}", :verbose => false
          end
        end
        
        # This method extracts the tar file of DeckLink driver. AI will first check whether the tar files have been
        # extracted, if not, AI will create a working directory for the tar file and extract the tar file into the 
        # newly created directory.
        #
        def extract
          if Path.packages.directory?
            UI.warn "The tar file will not be extracted, because package repository already exist: #{Path.packages.enquote}"
          else
            UI.info "Extracting DeckLink drivers".green.bold
            Cmd.mkdir Path.packages
            Cmd.cd Path.packages, :internal => true
            Cmd.run "tar -xzf #{Path.tar}"
          end
        end
        
        # The method executes the Debian package of thex
        def apply
          Cmd.cd Path.packages, :internal => true
          archflag = Gem::Platform.local.cpu =~ /64/ ? 'amd64' : 'i386'
          file = Dir[File.join(Path.packages, "Deck*#{archflag}*.deb")]
          UI.debug "#{self.class} identified these applicable packages: #{file.join(', ')}"
          UI.info "Installing Debian packages".green.bold
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.join(' ')} --yes --force-yes", :announce_pwd => false
          Cmd.run "sudo dpkg -i #{file.first || '[DRIVER FILE FOR THIS ARCHITECTURE]'}", :announce_pwd => false
        end
        
        def add_boot_loader
          content = Path.kernel_module.file? ? File.read(Path.kernel_module) : ''
          if content !~ /\nblackmagic/m or Options.reveal
            UI.info "Adding Blackmagic drivers to the boot loader".green.bold
            Cmd.touch_and_replace_content Path.new_kernel_module, "#{content}\nblackmagic"
            Cmd.run "sudo cp #{Path.new_kernel_module} #{Path.kernel_module}", :announce_pwd => false
          end
        end
        
        def send_notification
          Cmd.run %{notify-send --icon=gdm-setup "DeckLink installation complete" "You are now ready to use your Blackmagic Design DeckLink device." }, :internal => true, :die_on_failure => false
        end
        
        def define_relative_paths
          blacklink_repository   = 'http://www.blackmagic-design.com/downloads/software/'
          decklink_basename      = 'DeckLink_Linux_7.7.3'
          decklink_extension     = '.tar.gz'
          Path.decklink_url      = blacklink_repository + decklink_basename + decklink_extension
          Path.tar               = Pathname.new(File.join(Path.work, "#{decklink_basename + decklink_extension}"))
          Path.packages          = Pathname.new(File.join(Path.work, decklink_basename))
          Path.new_kernel_module = Pathname.new(File.join(Path.work, 'modules'))
          Path.kernel_module     = Pathname.new(File.join('/', 'etc', 'modules'))
        end
        
      end
    end
  end
end