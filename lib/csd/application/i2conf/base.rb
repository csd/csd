# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'
require 'csd/application/minisip/unix/linux/debian'
require 'csd/application/i2conf/config_example'

module CSD
  module Application
    module I2conf
      class Base < CSD::Application::Base
        
        include ::CSD::Application::Minisip::Component
        
        DESKTOP_ENTRY = %{
[Desktop Entry]
Encoding=UTF-8
Name=i2conf MCU
GenericName=SIP Multipoint Control Unit (Reflector)
Comment=Provide a multi-party video conference room
Exec=PLACEHOLDER
Icon=i2conf_gnome
Terminal=true
Type=Application
StartupNotify=true
Categories=Application;Internet;Network;Chat;AudioVideo}
        
        GNOME_ICON_URL = 'http://github.com/downloads/csd/i2conf/i2conf_gnome.png'
        
        # A list of apt-get packages that are required to install i2conf.
        #
        DEBIAN_DEPENDENCIES = %w{ libboost-dev libboost-thread-dev liblog4cxx* }
        
        def install
          @minisip = ::CSD::Application::Minisip::Debian.new
          define_relative_paths
          UI.separator
          UI.info "This operation will download and install the i2conf SIP video conferencing MCU.".green.bold
          UI.separator
          introduction
          install!
        end
        
        def install!
          create_working_directory
          compile_minisip
          aptitude
          checkout_strmanager
          copy_libtool
          fix_str_manager
          compile_str_manager
          checkout_i2conf
          fix_i2conf
          fix_i2conf_aclocal
          compile_i2conf
          create_desktop_entry
          configure_i2conf
          send_notification
          congratulations
        end
        
        def compile_minisip
          return unless Options.minisip
          @minisip.aptitude
          Options.only = %w{ libmutil libmnetutil libmcrypto libmikey libmsip libmstun libminisip }
          Options.blank_minisip_configuration = true
          Options.bootstrap = true
          Options.configure = true
          Options.make = true
          Options.make_install = true
          Core.checkout
          Core.modify_dirlist
          Core.compile_libraries
          Core.link_libraries
        end
        
        def aptitude
          return unless Options.apt_get
          UI.info "Installing Debian dependencies for i2conf".green.bold
          Cmd.run 'sudo apt-get update', :announce_pwd => false
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.sort.join(' ')} --yes --fix-missing", :announce_pwd => false
        end
        
        def checkout_strmanager
          Cmd.git_clone('strManager library', 'git://github.com/csd/strManager.git', Path.str_manager)
        end
        
        def copy_libtool
          UI.info 'Copying libtool dependencies'.green.bold
          Cmd.cd Path.str_manager, :internal => true
          Cmd.run 'cp /usr/share/libtool/config/config.sub .'
          Cmd.run 'cp /usr/share/libtool/config/config.guess .'
          Cmd.run 'cp /usr/share/libtool/config/ltmain.sh .'
        end
        
        def fix_str_manager
          UI.info 'Fixing strManager'.green.bold
          [Path.str_src_manager, Path.str_src_worker].each do |file|
            if Options.reveal or !File.read(file).include?('#include <iostream>')
              Cmd.replace file, '#include', "#include <iostream>\n#include", { :only_first_occurence => true }
            end
          end
        end
        
        def compile_str_manager
          UI.info 'Compiling strManager'.green.bold
          Cmd.cd Path.str_manager, :internal => true
          Cmd.run './configure'
          Cmd.run 'aclocal'
          Cmd.run 'make'
          Cmd.run 'sudo make install'
          Cmd.run "sudo ldconfig /usr/local/lib/libstrmanager.so", :announce_pwd => false
        end
        
        def checkout_i2conf
          Cmd.git_clone('i2conf repository', 'git://github.com/csd/i2conf.git', Path.i2conf)
        end
        
        def fix_i2conf
          if Options.reveal or !File.read(Path.i2conf_bootstrap).include?('automake-1.11')
            UI.info 'Fixing i2conf automake'.green.bold
            Cmd.replace Path.i2conf_bootstrap, 'elif automake-1.10', %{elif automake-1.11 --version >/dev/null 2>&1; then\n  amvers="-1.11"\nelif automake-1.10}, { :only_first_occurence => true }
          end
        end
        
        def fix_i2conf_aclocal
          if Options.reveal or File.read(Path.i2conf_bootstrap).include?('-I m4')
            UI.info 'Fixing i2conf aclocal'.green.bold
            Cmd.replace Path.i2conf_bootstrap, '-I m4 ', ''
          end
        end
        
        def compile_i2conf
          UI.info 'Compiling i2conf'.green.bold
          Cmd.cd Path.i2conf, :internal => true
          Cmd.run './bootstrap'
          Cmd.run './configure'
          Cmd.run 'aclocal'
          Cmd.run 'make'
          Cmd.run 'sudo make install'
        end
        
        def create_desktop_entry
          UI.info "Installing Gnome menu item".green.bold
          if Cmd.download(GNOME_ICON_URL, Path.i2conf_gnome_png).success?
            Cmd.run("sudo cp #{Path.i2conf_gnome_png} #{Path.i2conf_gnome_pixmap}", :announce_pwd => false)
            Cmd.touch_and_replace_content Path.i2conf_new_desktop_entry, DESKTOP_ENTRY.sub('PLACEHOLDER', "i2conf -f #{Path.i2conf_example_conf}"), :internal => true
            Cmd.run "sudo mv #{Path.i2conf_new_desktop_entry} #{Path.i2conf_desktop_entry}", :announce_pwd => false
            Gnome.update_gnome_menu_cache
          else
            UI.warn "The menu item could not be created, because the image file could not be downloaded from #{GNOME_ICON_URL}.".green.bold
          end
        end
                
        def configure_i2conf
          if Path.i2conf_example_conf.file?
            UI.warn "Creating no example configuration file, because it already exists: #{Path.i2conf_example_conf}. "
          else
            UI.info "Creating example i2conf configuration file".green.bold
            Cmd.touch_and_replace_content Path.i2conf_example_conf, ::CSD::Application::I2conf::CONFIG_EXAMPLE
          end
        end

        def send_notification
          Cmd.run %{notify-send --icon=i2conf_gnome "I2conf installation complete" "You are now ready to use your SIP MCU." }, :internal => true, :die_on_failure => false
        end
        
        def congratulations
          cleanup_working_directory if Options.temp
          UI.separator
          UI.info "  i2conf installation complete.".green.bold
          UI.separator
          UI.info "  1. Change the password in the example configuration file:".yellow
          UI.info "     #{Path.i2conf_example_conf}".cyan
          UI.separator
          UI.info "  2. Start the MCU".yellow
          UI.info "     Application menu -> Internet".cyan
          UI.info "     or"
          UI.info "     i2conf -f #{Path.i2conf_example_conf}".cyan
          UI.separator
        end
        
        def introduction
          UI.info " Working directory:       ".green.bold + Path.work.to_s.yellow
          if Options.debug
            UI.info " Your Platform:           ".green + Gem::Platform.local.humanize.to_s.yellow
            UI.info(" Application module:      ".green + self.class.name.to_s.yellow)
          end
          UI.separator
          if Options.help
            UI.info Options.helptext
            # Cleanup in case the working directory was temporary and is empty
            Path.work.rmdir if Options.temp and Path.work.directory? and Path.work.children.empty?
            raise CSD::Error::Argument::HelpWasRequested
          else
            raise Interrupt unless Options.yes or Options.reveal or UI.continue?
          end
        end
        
        def define_relative_paths
          UI.debug "#{self.class}#define_relative_paths defines relative i2conf paths now"
          Path.str_manager              = Pathname.new(File.join(Path.work, 'libstrmanager'))
          Path.str_src_manager          = Pathname.new(File.join(Path.str_manager, 'src', 'Manager.cpp'))
          Path.str_src_worker           = Pathname.new(File.join(Path.str_manager, 'src', 'workers', 'StatsWorker.cpp'))
          Path.i2conf                   = Pathname.new(File.join(Path.work, 'i2conf'))
          Path.i2conf_bootstrap         = Pathname.new(File.join(Path.i2conf, 'bootstrap'))
          Path.i2conf_example_conf      = Pathname.new(File.join(ENV['HOME'], 'i2conf.example.xml'))
          Path.i2conf_gnome_png         = Pathname.new(File.join(Path.work, 'i2conf_gnome.png'))
          Path.i2conf_gnome_pixmap      = Pathname.new(File.join('/', 'usr', 'share', 'pixmaps', 'i2conf_gnome.png'))
          Path.i2conf_desktop_entry     = Pathname.new(File.join('/', 'usr', 'share', 'applications', 'i2conf.desktop'))
          Path.i2conf_new_desktop_entry = Pathname.new(File.join(Path.work, 'i2conf.desktop'))
        end
        
      end
    end
  end
end