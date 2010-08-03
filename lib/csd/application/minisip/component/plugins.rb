# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Plugins
          class << self
            
            def compile
              UI.debug "#{self}.compile was called"
              if Path.plugins.directory? and !Options.reveal
                UI.warn "The optional MiniSIP plugins will not be installed, because the directory #{Path.plugins.enquote} already exists."
              else
                checkout
                copy
              end
            end
          
            def introduction
            end
          
            def checkout
              Cmd.git_clone('additional MiniSIP plugins', 'http://github.com/csd/minisip-plugins.git', Path.plugins)
            end
          
            # Copies the plugins from the repository to the final destination.
            #
            def copy
              if Path.plugins_destination.directory?
                UI.info "Installing optional MiniSIP plugins".green.bold
                UI.info "Copying from `#{Path.plugins_destination}´ to `#{Path.plugins}´".yellow
                Dir[File.join(Path.plugins, '{md,mg,mvideo}*.{a,la,so}')].each do |plugin|
                  if Gem::Platform.local.os == 'linux' or Gem::Platform.local.os == 'darwin'
                    optional_sudo = Options.this_user ? '' : 'sudo '
                    UI.info "  #{File.basename(plugin)}"
                    Cmd.run("#{optional_sudo}cp #{plugin} #{Path.plugins_destination}", :internal => true)
                  else
                    # On other platforms we will have to do this without superuser privileges for now
                    Cmd.copy(plugin, Path.plugins_destination)
                  end
                end
              else
                UI.warn "The target plugin directory could not be found: #{Path.plugins_destination.enquote}".green.bold
              end
            end
          
          end
        end
      end
    end
  end
end
