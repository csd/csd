# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'default', 'base')

module CSD
  module Application
    module Minisip
      class Base < CSD::Application::Base
        
        LIBRARIES = %w{ libmutil libmnetutil libmcrypto libmikey libmsip libmstun libminisip minisip } unless defined?(LIBRARIES)

        def package
          UI.error 'Currently not supported for this platform. Sorry.'
        end
        
        def compile
          UI.error 'Currently not supported for this platform. Sorry.'
        end
        
        def define_root_path
          if Options.path
            if File.directory?(Options.path)
              Path.root = File.expand_path(Options.path)
            else
              raise Error::Options::PathNotFound, "The path `#{Options.path}´ doesn't exist."
            end
          else
            Path.root = Options.temp ? Dir.mktmpdir : Dir.pwd
          end
        end
        
        def define_paths
          Path.work                      = Pathname.new(File.join(Path.root, 'minisip'))
          Path.repository                = Pathname.new(File.join(Path.work, 'repository'))
          Path.plugins                   = Pathname.new(File.join(Path.work, 'plugins'))
          Path.packaging                 = Pathname.new(File.join(Path.work, 'packaging'))
          Path.open_gl_display           = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'display', 'OpenGLDisplay.cxx'))
          Path.hdviper                   = Pathname.new(File.join(Path.work, 'hdviper'))
          Path.hdviper_x264              = Pathname.new(File.join(Path.hdviper, 'x264'))
          Path.hdviper_x264_test_x264api = Pathname.new(File.join(Path.hdviper_x264, 'test', 'x264API'))
          Path.build                     = Pathname.new(File.join(Path.work, 'build'))
          Path.build_bin                 = Pathname.new(File.join(Path.build, 'bin'))
          Path.build_gtkgui              = Pathname.new(File.join(Path.build_bin, 'minisip_gtkgui'))
          Path.build_include             = Pathname.new(File.join(Path.build, 'include'))
          Path.build_lib                 = Pathname.new(File.join(Path.build, 'lib'))
          Path.build_lib_pkg_config      = Pathname.new(File.join(Path.build_lib, 'pkgconfig'))
          Path.build_share               = Pathname.new(File.join(Path.build, 'share'))
          Path.build_share_aclocal       = Pathname.new(File.join(Path.build_share, 'aclocal'))
          Path.giomm_header              = Pathname.new(File.join('/', 'usr', 'include', 'giomm-2.4', 'giomm.h'))
        end
        
        def checkout_minisip # TODO: Refactor because redudancy with checkout_hdviper
          if Path.repository.directory?
            UI.warn "Skipping repository download, because the directory already exists: #{Path.repository}"
          else
            if Path.repository.parent.writable? or Options.dry
              UI.info "Downloading minisip repository to: #{Path.repository}".green.bold
              Cmd.run("git clone http://github.com/csd/minisip.git #{Path.repository}")
              # Fixing hard-coded stuff
              Cmd.replace(Path.open_gl_display, '/home/erik', Path.build)
            else
              UI.error "Could not download minisip repository (no permission): #{Path.repository}"
            end
          end
        end
        
        def checkout_plugins # TODO: Refactor because redudancy with checkout_hdviper
          if Path.plugins.directory?
            UI.warn "Skipping plugins download, because the directory already exists: #{Path.plugins}"
          else
            if Path.plugins.parent.writable? or Options.dry
              UI.info "Downloading minisip plugins to: #{Path.plugins}".green.bold
              Cmd.run("git clone http://github.com/csd/minisip-plugins.git #{Path.plugins}")
            else
              UI.error "Could not download minisip plugins (no permission): #{Path.plugins}"
            end
          end
        end
        
        def checkout_hdviper
          if Path.hdviper.directory?
            UI.warn "Skipping hdviper, because the directory already exists: #{Path.hdviper}"
          else
            if Path.hdviper.parent.writable? or Options.dry
              UI.info "Downloading hdviper to: #{Path.hdviper}".green.bold
              Cmd.run("git clone http://github.com/csd/libraries.git #{Path.hdviper}")
              #Cmd.run("svn co --quiet svn://hdviper.org/hdviper/wp3/src #{Path.hdviper}")
              return true
            else
              UI.error "Could not download hdviper (no permission): #{Path.hdviper}"
            end
          end
        end
        
        def before_compile
        end

        def after_compile
        end
        
      end
    end
  end
end