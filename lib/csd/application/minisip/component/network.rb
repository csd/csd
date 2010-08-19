# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Network
          class << self
            
            def compile
              UI.debug "#{self}.compile was called"
              lsmod = Cmd.run 'lsmod', :die_on_failure => false, :internal => true
              update_realtek if lsmod.success? and lsmod.output !~ /r8168/
            end
            
            def update_realtek
              checkout_realtek
              compile_realtek
            end
            
            def checkout_realtek
              Cmd.git_clone 'Realtek firmware', 'git://github.com/csd/realtek.git', Path.realtek_firmware
            end
            
            def compile_realtek
              UI.info 'Installing the latest Realtek firmware'
              Cmd.cd Path.realtek_firmware, :internal => true
              Cmd.run 'sudo ./autorun.sh'
            end
            
            def introduction
            end
            
          end
        end
      end
    end
  end
end
