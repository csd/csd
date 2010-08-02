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
              # TODO: Find out how to determine the destination path for the plugins
              # UI.info "Creating plugin target directory".green.bold
              # result = Path.plugins_destination.parent.directory? ? Cmd.run("sudo mkdir #{Path.plugins_destination}") : CommandResult.new
              Cmd.copy(Dir[File.join(Path.plugins, '{m}*.{l,la,so}')], Path.plugins_destination) if Path.plugins_destination.directory?
            end
          
          end
        end
      end
    end
  end
end
