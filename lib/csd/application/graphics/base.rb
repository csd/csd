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
          determine_graphics_card
        end
        
        def introduction
          
        end
        
        def determine_graphics_card
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
          
        end
        
        def install_geforce
          Cmd.git_clone 'drivers for nVIDIA GeForce', 'git://github.com/csd/nvidia.git', Path.geforce
          Cmd.run "chmod +x #{Path.geforce_run}", :announce_pwd => false
          Cmd.run "sudo #{Path.geforce_run}", :announce_pwd => false
        end
        
        def define_relative_paths
          UI.debug "#{self.class}#define_relative_paths defines relative graphics paths now"
          Path.radeon       = Pathname.new(File.join(Path.work, 'radeon'))
          Path.geforce      = Pathname.new(File.join(Path.work, 'geforce'))
          Path.geforce_run  = Pathname.new(File.join(Path.geforce, 'NVIDIA-Linux-x86-256.44.run.sh'))
        end
        
      end
    end
  end
end
