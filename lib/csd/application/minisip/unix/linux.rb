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
          fix_ubuntu_10_04 if Gem::Platform.local.kernel_version == '#36-Ubuntu SMP Thu Jun 3 22:02:19 UTC 2010'
          make_minisip
          after_compile
        end
        
      end
    end
  end
end