# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Network
          class << self
            
            # These IP stack buffer values have been identified as optimal by the Master Thesis students.
            # Feel free to experiment around with other values. Erik suspects that they might have to be
            # higher than this.
            #
            OPTIMUM_BUFFERS = {
              'net.core.rmem_max'     => '131071',
              'net.core.wmem_max'     => '131071',
              'net.core.rmem_default' => '114688',
              'net.core.wmem_default' => '114688',
              'net.ipv4.udp_mem'      => '81120 108160 162240',
              'net.ipv4.udp_rmem_min' => '4096',
              'net.ipv4.udp_wmem_min' => '4096'
            }
            
            def compile
              UI.debug "#{self}.compile was called"
              fix_udp_buffer
              permanent_udp_buffer
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
              OPTIMUM_BUFFERS.each do |key, value|
                Cmd.run %{sudo sysctl -w #{key}="#{value}"}, :announce_pwd => false
              end
            end
            
            def permanent_udp_buffer
              if Path.sysctl_conf_backup.file? and !Options.reveal
                UI.warn "The UDP buffer modifications seems to be permanent already. Delete #{Path.sysctl_conf_backup.enquote} to enforce it."
              else
                UI.info 'Making the UDP buffer modifications permanent'.green.bold
                content = Path.sysctl_conf.file? ? File.read(Path.sysctl_conf) : ''
                Cmd.copy Path.sysctl_conf, Path.new_sysctl_conf
                UI.info "Adding modifications to #{Path.new_sysctl_conf}".cyan
                modifications = ['# Changes made by the AI'] + OPTIMUM_BUFFERS.map { |key, value| %{#{key} = #{value}} }
                modifications = content + "\n" + modifications.join("\n")
                Cmd.touch_and_replace_content Path.new_sysctl_conf, modifications, :internal => true
                # We cannot use Cmd.copy here, because Cmd.copy has no superuser privileges.
                # And since we are for sure on Ubuntu, these commands will work.
                Cmd.run "sudo cp #{Path.sysctl_conf} #{Path.sysctl_conf_backup}", :announce_pwd => false
                Cmd.run "sudo cp #{Path.new_sysctl_conf} #{Path.sysctl_conf}", :announce_pwd => false
              end
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
