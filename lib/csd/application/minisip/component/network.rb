# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Network
          class << self
            
            def compile
              UI.debug "#{self}.compile was called"
              fix_udp_buffer
              UI.info 'Determining network interface card'.green.bold
              lsmod = Cmd.run 'lsmod', :die_on_failure => false, :internal => true
              lspci = Cmd.run 'lspci -v | grep Ethernet', :die_on_failure => false, :internal => true
              UI.debug "#{self}.compile had this lsmod output: #{lsmod.output}"
              UI.debug "#{self}.compile had this lspci output: #{lspci.output}"
              update_realtek if (lsmod.success? and lsmod.output !~ /r8168/ and lspci.output =~ /RTL8111\/8168B/) or Options.reveal
              update_intel if (lspci.success? and lspci.output =~ /82572EI/) or Options.reveal
            end
            
            def fix_udp_buffer
              return unless Gem::Platform.local.debian? or Options.reveal
              UI.info 'Fixing UDP buffer size'.green.bold
              Cmd.run 'sudo sysctl -w net.core.rmem_max=8000000', :announce_pwd => false
              Cmd.run 'sudo sysctl -w net.core.rmem_default=8000000', :announce_pwd => false
            end
            
            def update_realtek
              checkout_realtek
              compile_realtek
            end

            def update_intel
              checkout_intel
              compile_intel
            end
            
            def checkout_realtek
              Cmd.git_clone 'Realtek firmware', 'git://github.com/csd/realtek.git', Path.realtek_firmware
            end
            
            def checkout_intel
              Cmd.git_clone 'Intel firmware', 'git://github.com/csd/intel.git', Path.intel_firmware
            end
            
            def compile_realtek
              UI.info 'Compiling Realtek firmware'.green.bold
              Cmd.cd Path.realtek_firmware, :internal => true
              Cmd.run 'sudo ./autorun.sh'
            end
            
            def compile_intel
              UI.info 'Compiling Intel firmware'.green.bold
              Cmd.cd Path.intel_firmware_src, :internal => true
              Cmd.run 'sudo make install'
            end
            
            def introduction
            end
            
          end
        end
      end
    end
  end
end
