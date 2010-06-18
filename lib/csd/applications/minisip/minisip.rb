require File.relative(__FILE__, '..', 'base')

module CSD
  module Application
    module Minisip
      class Minisip < CSD::Application::Base
        
        def introduction
          super
          define_paths
          say " Working directory:   ".green + path.work.to_s.yellow
          say " Your Platform:       ".green + Gem::Platform.local.humanize.to_s.yellow
          say " Application module:  ".green + self.class.name.to_s.yellow
          say
          unless options.yes
            exit unless ask_yes_no("Continue?".red.bold, true)
          end
          say
          build!
        end
        
        def build!
          before_build
          cd path.work
          make_hdviper if checkout_hdviper or options.dry
          checkout_minisip
          make_minisip
          after_build
        end

        def define_paths
          path.work                      = Pathname.new(File.join(path.root, 'minisip'))
          path.repository                = Pathname.new(File.join(path.work, 'repository'))
          path.open_gl_display           = Pathname.new(File.join(path.repository, 'libminisip', 'source', 'subsystem_media', 'video', 'display', 'OpenGLDisplay.cxx'))
          path.hdviper                   = Pathname.new(File.join(path.work, 'hdviper'))
          path.hdviper_x264              = Pathname.new(File.join(path.hdviper, 'x264'))
          path.hdviper_x264_test_x264api = Pathname.new(File.join(path.hdviper_x264, 'test', 'x264API'))
          path.build                     = Pathname.new(File.join(path.work, 'build'))
          path.build_include             = Pathname.new(File.join(path.build, 'include'))
          path.build_lib                 = Pathname.new(File.join(path.build, 'lib'))
          path.build_lib_pkg_config      = Pathname.new(File.join(path.build_lib, 'pkgconfig'))
          path.build_share               = Pathname.new(File.join(path.build, 'share'))
          path.build_share_aclocal       = Pathname.new(File.join(path.build_share, 'aclocal'))
        end
        
        def checkout_hdviper
          if path.hdviper.directory?
            say "Skipping hdviper, because the directory already exists: #{path.hdviper}".green.bold
          else
            if path.hdviper.parent.writable? or options.dry
              say "Downloading hdviper to: #{path.hdviper}".green.bold
              run_command("svn co --quiet svn://hdviper.org/hdviper/wp3/src #{path.hdviper}")
              return true
            else
              say "Could not download hdviper (no permission): #{path.hdviper}".red
            end
          end
        end
        
        def make_hdviper
          cd path.hdviper_x264
          run_command('./configure')
          run_command('make')
          cd path.hdviper_x264_test_x264api
          run_command('make')
        end
        
        def checkout_minisip # TODO: Refactor because redudancy with checkout_hdviper
          if path.repository.directory?
            say "Skipping repository download, because the directory already exists: #{path.repository}".green.bold
          else
            if path.repository.parent.writable? or options.dry
              say "Downloading minisip repository to: #{path.repository}".green.bold
              run_command("git clone http://github.com/csd/minisip.git #{path.repository}")
              # Fixing hard-coded stuff
              new_file_content = File.read(path.open_gl_display).gsub('/home/erik', path.build)
              File.open(path.open_gl_display, 'w+') { |file| file << new_file_content }
              return true
            else
              say "Could not download minisip repository (no permission): #{path.hdviper}".red
            end
          end
        end
        
        def make_minisip
          [path.build, path.build_include, path.build_lib, path.build_share, path.build_share_aclocal].each { |target| mkdir target }
          ['libmutil', 'libmnetutil', 'libmcrypto', 'libmikey', 'libmsip', 'libmstun', 'libminisip', 'minisip'].each do |library|
            directory = Pathname.new(File.join(path.repository, library))
            next if options.only and !options.only.include?(library)
            if cd(directory) or options.dry
              if options.bootstrap
                say "Bootstrapping #{library}".green.bold
                run_command("./bootstrap -I #{path.build_share_aclocal.enquote}")
              end
              if options.configure
                say "Configuring #{library}".green.bold
                individual_options = case library
                  when 'libminisip'
                    %Q{--enable-debug --enable-video --disable-mil --disable-decklink --enable-opengl --disable-sdl CPPFLAGS="-I#{path.hdviper_x264_test_x264api} -I#{path.hdviper_x264}" LDFLAGS="#{File.join(path.hdviper_x264_test_x264api, 'libx264api.a')} #{File.join(path.hdviper_x264_test_x264api 'libtidx264.a')} -lpthread -lrt"}
                  when 'minisip'
                    %Q{--enable-debug --enable-video --enable-textui --enable-opengl}
                  else
                    ''
                end
                run_command(%Q{./configure #{individual_options} --prefix=#{path.build.enquote} PKG_CONFIG_PATH=#{path.build_lib_pkg_config.enquote} ACLOCAL_FLAGS=#{path.build_share_aclocal} LD_LIBRARY_PATH=#{path.build_lib.enquote} --silent})
              end
              if options.make
                say "Make #{library}".green.bold
                run_command("make")
              end
              if options.make_install
                say "Make install #{library}".green.bold
                run_command("make install")
              end
            else
              say "Skipping minisip library #{library} because it not be found: #{directory}".green.bold
            end
          end
        end
        
      end
    end
  end
end