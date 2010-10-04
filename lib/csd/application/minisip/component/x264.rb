# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        # This module compiles X264 libraries.
        #
        module X264
          class << self
            
            # This method compiles X264 libraries by initiating corresponding modules. AI will first check whether
            # X264 source code has been already in the current directory, it will execute the checkout and make process only when
            # the source code is not there.
            #
            def compile
              UI.debug "#{self}.compile was called"
              if Path.x264_repository.directory? and !Options.reveal
                UI.warn "x264 will not be processed, because the directory #{Path.x264_repository.enquote} already exists."
              else
                checkout
                make
              end
            end
            
            # There is no actual operation for this introduction method.
            #
            def introduction
            end
            
            # This methos checkout x264 source code from git repository.
            #
            def checkout
              Cmd.git_clone('x264 repository', 'http://github.com/csd/x264.git', Path.x264_repository)
            end
            
            # This method compiles x264, given that x264 was downloaded before.
            #
            def make
              UI.info "Compiling and installing x264".green.bold
              Cmd.cd Path.x264_repository, :internal => true
              Cmd.run('./configure')
              Cmd.run "make -j #{Options.threads}"
              Cmd.run('sudo checkinstall --pkgname=x264 --pkgversion "99:-`git log -1 --pretty=format:%h`" --backup=no --default')
            end
            
          end
        end
      end
    end
  end
end