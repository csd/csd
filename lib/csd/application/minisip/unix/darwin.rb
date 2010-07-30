# -*- encoding: UTF-8 -*-
require 'csd/application/minisip/unix'

module CSD
  module Application
    module Minisip
      class Darwin < Unix

        def compile!
          Cmd.mkdir Path.work
          #checkout_hdviper
          #make_hdviper
          checkout_minisip
          modify_minisip
          checkout_plugins
          make_minisip
        end
        
      end
    end
  end
end