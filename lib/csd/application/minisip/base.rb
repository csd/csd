require File.join(File.dirname(__FILE__), '..', 'default', 'base')

module CSD
  module Application
    module Minisip
      class Base < CSD::Application::Base
        
        def introduction
          define_root_path
          define_paths
          UI.info " Working directory:   ".green + Path.work.to_s.yellow
          UI.info " Your Platform:       ".green + Gem::Platform.local.humanize.to_s.yellow
          UI.info " Application module:  ".green + self.class.name.to_s.yellow
          UI.separator
          unless Options.yes
            exit unless ask_yes_no("Continue?".red.bold, true)
          end
          UI.separator
          build!
        end
        
        def build!
          before_build
          Cmd.mkdir Path.work
          make_hdviper if checkout_hdviper or Options.dry
          checkout_minisip
          make_minisip
          after_build
        end
        
        def define_root_path
          if Options.path
            if File.directory?(Options.path)
              Path.root = File.expand_path(Options.path)
            else
              raise OptionsPathNotFound, "The path `#{Options.path}´ doesn't exist."
            end
          else
            Path.root = Options.temp ? Dir.mktmpdir : Dir.pwd
          end
        end

        def define_paths
          Path.work                      = Pathname.new(File.join(Path.root, 'minisip'))
          Path.repository                = Pathname.new(File.join(Path.work, 'repository'))
          Path.open_gl_display           = Pathname.new(File.join(Path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'display', 'OpenGLDisplay.cxx'))
          Path.hdviper                   = Pathname.new(File.join(Path.work, 'hdviper'))
          Path.hdviper_x264              = Pathname.new(File.join(Path.hdviper, 'x264'))
          Path.hdviper_x264_test_x264api = Pathname.new(File.join(Path.hdviper_x264, 'test', 'x264API'))
          Path.build                     = Pathname.new(File.join(Path.work, 'build'))
          Path.build_include             = Pathname.new(File.join(Path.build, 'include'))
          Path.build_lib                 = Pathname.new(File.join(Path.build, 'lib'))
          Path.build_lib_pkg_config      = Pathname.new(File.join(Path.build_lib, 'pkgconfig'))
          Path.build_share               = Pathname.new(File.join(Path.build, 'share'))
          Path.build_share_aclocal       = Pathname.new(File.join(Path.build_share, 'aclocal'))
        end
        
        def checkout_hdviper
          if Path.hdviper.directory?
            UI.warn "Skipping hdviper, because the directory already exists: #{Path.hdviper}"
          else
            if Path.hdviper.parent.writable? or Options.dry
              UI.info "Downloading hdviper to: #{Path.hdviper}".green.bold
              Cmd.run("git clone http://github.com/csd/libraries.git #{Path.hdviper}", :die_on_failure => true)
              #Cmd.run("svn co --quiet svn://hdviper.org/hdviper/wp3/src #{Path.hdviper}")
              return true
            else
              UI.error "Could not download hdviper (no permission): #{Path.hdviper}"
            end
          end
        end
        
        def make_hdviper
          Cmd.cd Path.hdviper_x264
          Cmd.run('./configure')
          Cmd.run('make')
          Cmd.cd Path.hdviper_x264_test_x264api
          Cmd.run('make')
        end
        
        def checkout_minisip # TODO: Refactor because redudancy with checkout_hdviper
          if Path.repository.directory?
            UI.warn "Skipping repository download, because the directory already exists: #{Path.repository}"
          else
            if Path.repository.parent.writable? or Options.dry
              UI.info "Downloading minisip repository to: #{Path.repository}".green.bold
              Cmd.run("git clone http://github.com/csd/minisip.git #{Path.repository}", :die_on_failure => true)
              # Fixing hard-coded stuff
              Cmd.replace(Path.open_gl_display, '/home/erik', Path.build)
            else
              UI.error "Could not download minisip repository (no permission): #{Path.hdviper}"
            end
          end
        end
        
        def make_minisip
          [Path.build, Path.build_include, Path.build_lib, Path.build_share, Path.build_share_aclocal].each { |target| Cmd.mkdir target }
          ['libmutil', 'libmnetutil', 'libmcrypto', 'libmikey', 'libmsip', 'libmstun', 'libminisip', 'minisip'].each do |library|
            directory = Pathname.new(File.join(Path.repository, library))
            next if Options.only and !Options.only.include?(library)
            if Cmd.cd(directory) or Options.dry
              if Options.bootstrap
                UI.info "Bootstrapping #{library}".green.bold
                Cmd.run("./bootstrap -I #{Path.build_share_aclocal.enquote}", :die_on_failure => true)
              end
              if Options.configure
                UI.info "Configuring #{library}".green.bold
                individual_options = case library
                  when 'libminisip'
                    %Q{--enable-debug --enable-video --disable-mil --enable-decklink --enable-opengl --disable-sdl CPPFLAGS="-I#{Path.hdviper_x264_test_x264api} -I#{Path.hdviper_x264}" LDFLAGS="#{File.join(Path.hdviper_x264_test_x264api, 'libx264api.a')} #{File.join(Path.hdviper_x264, 'libtidx264.a')} -lpthread -lrt"}
                    #%Q{--enable-debug --enable-video --disable-mil --disable-decklink --enable-opengl --disable-sdl CPPFLAGS="-I#{Path.hdviper_x264}" LDFLAGS="#{File.join(Path.hdviper_x264, 'libx264.a')} -lpthread -lrt"}
                  when 'minisip'
                    %Q{--enable-debug --enable-video --enable-textui --enable-opengl}
                  else
                    ''
                end
                Cmd.run(%Q{./configure #{individual_options} --prefix=#{Path.build.enquote} PKG_CONFIG_PATH=#{Path.build_lib_pkg_config.enquote} ACLOCAL_FLAGS=#{Path.build_share_aclocal} LD_LIBRARY_PATH=#{Path.build_lib.enquote} --silent}, :die_on_failure => true)
              end
              if Options.make
                UI.info "Make #{library}".green.bold
                Cmd.run("make", :die_on_failure => true)
              end
              if Options.make_install
                UI.info "Make install #{library}".green.bold
                Cmd.run("make install", :die_on_failure => true)
              end
            else
              UI.warn "Skipping minisip library #{library} because it not be found: #{directory}".green.bold
            end
          end
        end
        
      end
    end
  end
end