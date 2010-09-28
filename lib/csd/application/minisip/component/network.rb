# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        # This module updates the network firmware of the system.
        #
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
            
            # This method fixes the udp buffer size and updates the suitable network firmware after auto detection.
            # AI will first use the optimum buffer parameters, which have been tested and identified, to update
            # the system and then make them permanent in the system. AI will also detect the system for its network card,
            # and initiate the corresponding method to update it.
            #
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
            
            # This method uses the optimum UDP buffer parameters for MiniSIP to update the system.
            #
            def fix_udp_buffer
              return unless Gem::Platform.local.debian? or Options.reveal
              UI.info 'Fixing UDP buffer size'.green.bold
              OPTIMUM_BUFFERS.each do |key, value|
                Cmd.run %{sudo sysctl -w #{key}="#{value}"}, :announce_pwd => false
              end
            end
            
            # This method makes the UDP buffer modification permanent. AI modifies the sysctl.conf file with the updated
            # values and creates a backup file for it. But before that, AI will first look for the backup file, if it
            # already exists, AI will consider the UDP buffer size parameters have been made permanent and do not 
            # touch any thing.
            # 
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
            
            # This method update realtek firmware by checking out and compiling it.
            #
            def update_realtek
              checkout_realtek
              compile_realtek
            end
            
            # This method update intel firmware by checking out and compiling it.
            #
            def update_intel
              checkout_intel
              compile_intel
            end
            
            # This method check out realtek firmware from git repository
            #
            def checkout_realtek
              Cmd.git_clone 'Realtek firmware', 'http://github.com/csd/realtek.git', Path.realtek_firmware
            end
            
            # This method check out intel firmware from git repository
            #
            def checkout_intel
              Cmd.git_clone 'Intel firmware', 'http://github.com/csd/intel.git', Path.intel_firmware
            end
            
            # This method compile realtek firmware by running the downloaded autorun shell script.
            # It also gives a UI information the users about the following operation.
            #
            def compile_realtek
              UI.info 'Compiling Realtek firmware'.green.bold
              Cmd.cd Path.realtek_firmware, :internal => true
              Cmd.run 'sudo ./autorun.sh'
            end
            
            # This method compile intel firmware by +make+ +install+ command.
            # It also gives a UI information the users about the following operation.
            #
            def compile_intel
              UI.info 'Compiling Intel firmware'.green.bold
              Cmd.cd Path.intel_firmware_src, :internal => true
              Cmd.run 'sudo make install'
            end
            
            # There is no actual operation for this introduction method.
            #
            def introduction
            end
            
          end
        end
      end
    end
  end
end
