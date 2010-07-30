# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module X264
          class << self
            
            def compile
              return if Path.x264_repository.directory?
              checkout
              make
            end
            
            def introduction
            end
            
            def checkout
              Cmd.git_clone('x264 repository', 'http://github.com/csd/x264.git', Path.x264_repository)
            end
            
            # This method compiles x264, given that x264 was downloaded before.
            #
            def make
              UI.info "Compiling and installing x264".green.bold
              Cmd.cd Path.x264_repository, :internal => true
              Cmd.run('./configure')
              Cmd.run('make')
              Cmd.run('sudo checkinstall --pkgname=x264 --pkgversion "99:-`git log -1 --pretty=format:%h`" --backup=no --default')
            end
            
          end
        end
      end
    end
  end
end