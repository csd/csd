# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Graphics
      class Base < CSD::Application::Base
        
        def install
          UI.separator
          UI.info "This operation will download and install the latest graphics card drivers.".green.bold
          UI.separator
          introduction
          install!
        end
        
        def install!
          define_relative_paths
          create_working_directory
          process_graphics_card
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
        
        def process_graphics_card
          case Cmd.run('lspci | grep VGA', :internal => true).output
            when /Radeon/
              install_radeon
            when /GeForce/
              install_geforce
            else
              raise Error::Graphics::CardNotSupported, "Sorry, currently only ATI Radeon and nVIDIA GeForce are supported"
          end
        end
        
        def install_radeon
          Cmd.git_clone 'drivers for ATI radeon', 'git://github.com/csd/ati.git', Path.radeon
          Cmd.run "chmod +x #{Path.radeon_run}", :announce_pwd => false
          proprietary_continue
          Cmd.run "sh #{Path.radeon_run}", :announce_pwd => false
        end
        
        def install_geforce
          raise Error::Graphics::Amd64NotSupported, "Sorry, nVIDIA GeForce is currently only supported on x86" unless Gem::Platform.local.cpu == 'x86' 
          Cmd.git_clone 'drivers for nVIDIA GeForce', 'git://github.com/csd/nvidia.git', Path.geforce
          Cmd.run "chmod +x #{Path.geforce_run}", :announce_pwd => false
          proprietary_continue
          Cmd.run "sudo #{Path.geforce_run}", :announce_pwd => false, :verbose =>true
        end
        
        def proprietary_continue
          UI.separator
          UI.info 'The proprietary installer for your graphic card will now be executed.'.green.bold
          UI.info 'Please follow the instructions manually.'.green.bold
          UI.separator
          unless UI.continue? or Options.reveal
           cleanup_working_directory
           raise Interrupt
          end
        end
        
        def define_relative_paths
          UI.debug "#{self.class}#define_relative_paths defines relative graphics paths now"
          Path.radeon       = Pathname.new(File.join(Path.work, 'radeon'))
          Path.radeon_run   = Pathname.new(File.join(Path.radeon, 'ati-driver-installer-10-7-x86.x86_64.run'))
          Path.geforce      = Pathname.new(File.join(Path.work, 'geforce'))
          Path.geforce_run  = Pathname.new(File.join(Path.geforce, 'NVIDIA-Linux-x86-256.44.run.sh'))
        end
        
      end
    end
  end
end
