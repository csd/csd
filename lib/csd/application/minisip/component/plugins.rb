# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Plugins
          
          def introduction
          end
          
          def checkout_plugins
            Cmd.git_clone('additional MiniSIP plugins', 'http://github.com/csd/minisip-plugins.git', Path.plugins)
          end
          
          # Copies the plugins from the repository to the final destination.
          #
          def copy_plugins
            UI.info "Creating plugin target directory".green.bold
            # result = Path.plugins_destination.parent.directory? ? Cmd.run("sudo mkdir #{Path.plugins_destination}") : CommandResult.new
            # TODO: This will maybe need sudo rights in the future
            Cmd.copy(Dir[File.join(Path.plugins, '*.{l,la,so}')], Path.plugins_destination) if Path.plugins_destination.directory?
          end
          
        end
      end
    end
  end
end
