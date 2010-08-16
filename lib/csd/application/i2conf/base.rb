# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'
require 'csd/application/minisip/unix/linux/debian'

module CSD
  module Application
    module I2conf
      class Base < CSD::Application::Base
        
        include ::CSD::Application::Minisip
        
        # A list of apt-get packages that are required to install i2conf.
        #
        DEBIAN_DEPENDENCIES = %w{ libboost-dev libboost-thread-dev liblog4cxx* }
        
        def install
          @minisip = ::CSD::Application::Minisip::Debian.new
          define_relative_paths
          UI.separator
          UI.info "This operation will download and install the i2conf SIP video conferencing MCU.".green.bold
          UI.separator
          introduction
          install!
        end
        
        def install!
          create_working_directory
          

          send_notification
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
        
        
        def send_notification
          Cmd.run %{notify-send --icon=gdm-setup "I2conf installation complete" "You are now ready to use your SIP MCU." }, :internal => true, :die_on_failure => false
        end
        
        def define_relative_paths
          UI.debug "#{self}#define_relative_paths defines relative i2conf paths now"
#          Path.packages          = Pathname.new(File.join(Path.work#, decklink_basename))
        end
        
      end
    end
  end
end