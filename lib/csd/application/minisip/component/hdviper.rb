# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module HDVIPER
          
          def checkout_hdviper
            Cmd.git_clone('HDVIPER', 'http://github.com/csd/libraries.git', Path.hdviper)
          end

          # This method compiles HDVIPER, given that HDVIPER was downloaded before.
          #
          def make_hdviper
            Cmd.cd Path.hdviper_x264, :internal => true
            Cmd.run('./configure')
            Cmd.run('make')
            Cmd.cd Path.hdviper_x264_test_x264api, :internal => true
            Cmd.run('make')
          end
          
        end
      end
    end
  end
end