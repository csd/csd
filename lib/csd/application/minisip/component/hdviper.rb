# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module HDVIPER
          class << self
            
            # This method processes HDVIPER.
            #
            def compile
              UI.debug "#{self}.compile was called"
              if Path.hdviper.directory? and !Options.reveal
                UI.warn "HDVIPER will not be processed, because the directory #{Path.hdviper.enquote} already exists."
              else
                checkout
                configure_and_make
              end
            end
            
            # This method informs about the HDVIPER process.
            #
            def introduction
            end
            
            # This method downloads the HDVIPER source code.
            #
            def checkout
              Cmd.git_clone('HDVIPER', 'http://github.com/csd/libraries.git', Path.hdviper)
            end
            
            # This method compiles HDVIPER, given that HDVIPER was downloaded before.
            #
            def configure_and_make
              UI.info "Compiling HDVIPER".green.bold
              Cmd.cd Path.hdviper_x264, :internal => true
              Cmd.run('./configure')
              Cmd.run "make -j #{Options.threads}"
              Cmd.cd Path.hdviper_x264_test_x264api, :internal => true
              Cmd.run "make -j #{Options.threads}"
            end
          
          end
        end
      end
    end
  end
end