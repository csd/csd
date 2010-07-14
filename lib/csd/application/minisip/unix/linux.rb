# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'unix')

module CSD
  module Application
    module Minisip
      class Linux < Unix
        
        def compile!
          before_compile
          Cmd.mkdir Path.work
          make_hdviper if checkout_hdviper or Options.dry
          checkout_minisip
          checkout_plugins
          make_minisip
          after_compile
        end
        
      end
    end
  end
end