# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'
require 'csd/application/minisip/unix/linux/debian'
require 'csd/application/i2conf/config_example'

module CSD
  module Application
    module I2conf
      class Base < CSD::Application::Base
        
        # This is to include MiniSIP component class, since MiniSIP need to be compiled before i2conf compilation.
        # Thus, in the i2conf module AI will load methods in MiniSIP component class directly to compile MiniSIP.
        #
        include ::CSD::Application::Minisip::Component
        
        # Necessary contents for i2conf .desktop file. It will be used in the method of create_desktop_entry.
        # 
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
        
        # This constant is to preserve the URL of the i2conf icon in github repository.
        #
        GNOME_ICON_URL = 'http://github.com/downloads/csd/i2conf/i2conf_gnome.png'
        
        # A list of apt-get packages that are required to install i2conf.
        #
        DEBIAN_DEPENDENCIES = %w{ libboost-dev libboost-thread-dev liblog4cxx* }
        
        # This method notifies users about following operation of AI, and initiates introduction method.
        # The actual installation process is carried out by method install! for the purpose of keeping source code clean.
        # 
        def install
          @minisip = ::CSD::Application::Minisip::Debian.new
          define_relative_paths
          UI.separator
          UI.info "This operation will download and install the i2conf SIP video conferencing MCU.".green.bold
          UI.separator
          introduction
          install!
        end
        
        # This method initiates corresponding methods sequentially to set up i2conf server.
        # 
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
        
        # This method compiles MiniSIP. Because i2conf will make use of MiniSIP libraries during the compilation process.
        # However, MiniSIP is compiled without any additional option during the configuration process, since full configuration
        # options cause conflict with 64bit system, while i2conf can also be run in 64bit system. Thus this operation assures
        # i2conf server can be set up on both 32 and 64 bits system.
        # 
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
        
        # This method installs all library dependencies of i2conf server.
        # It will first update the package index and then install all Debian dependencies.
        # AI will force the operation to continue without being interrupted by the request for user's approval
        # This is because users have been asked once about their willingness to continue in the introduction method,
        # thus AI will not bother users again for each of the library dependency.
        #
        def aptitude
          return unless Options.apt_get
          UI.info "Installing Debian dependencies for i2conf".green.bold
          Cmd.run 'sudo apt-get update', :announce_pwd => false
          Cmd.run "sudo apt-get install #{DEBIAN_DEPENDENCIES.sort.join(' ')} --yes --fix-missing", :announce_pwd => false
        end
        
        # The method checks out the Lib strManager source code from git repository.
        # strManager is a high-performance UDP packet reflector with high customizing per-flow options.
        # 
        def checkout_strmanager
          Cmd.git_clone('strManager library', 'git://github.com/csd/strManager.git', Path.str_manager)
        end
        
        # The method copies several files in libtool to the directory of strManager to avoid libtool version mismatch.
        #
        def copy_libtool
          UI.info 'Copying libtool dependencies'.green.bold
          Cmd.cd Path.str_manager, :internal => true
          Cmd.run 'cp /usr/share/libtool/config/config.sub .'
          Cmd.run 'cp /usr/share/libtool/config/config.guess .'
          Cmd.run 'cp /usr/share/libtool/config/ltmain.sh .'
        end
        
        # The method includes header file iostream into Manager.cpp and StatsWorker.cpp in the source code.
        #
        def fix_str_manager
          UI.info 'Fixing strManager'.green.bold
          [Path.str_src_manager, Path.str_src_worker].each do |file|
            if Options.reveal or !File.read(file).include?('#include <iostream>')
              Cmd.replace file, '#include', "#include <iostream>\n#include", { :only_first_occurence => true }
            end
          end
        end
        
        # The method compiles strManager.
        # After compilation process, it will run ldconfig on libstrmanager.so file to help
        # strManager to locate necessary MiniSIP libraries.
        #
        def compile_str_manager
          UI.info 'Compiling strManager'.green.bold
          Cmd.cd Path.str_manager, :internal => true
          Cmd.run './configure'
          Cmd.run 'aclocal'
          Cmd.run 'make -j 15'
          Cmd.run 'sudo make install'
          Cmd.run "sudo ldconfig /usr/local/lib/libstrmanager.so", :announce_pwd => false
        end
        
        # The method checks out i2conf source code from git repository.
        #
        def checkout_i2conf
          Cmd.git_clone('i2conf repository', 'git://github.com/csd/i2conf.git', Path.i2conf)
        end
        
        # The method fixes i2conf source code. The bootstrap file of i2conf only specifies automake version from 1.7 to 1.10.
        # AI will include the latest version 1.11 into its support list.
        # 
        def fix_i2conf
          if Options.reveal or !File.read(Path.i2conf_bootstrap).include?('automake-1.11')
            UI.info 'Fixing i2conf automake'.green.bold
            Cmd.replace Path.i2conf_bootstrap, 'elif automake-1.10', %{elif automake-1.11 --version >/dev/null 2>&1; then\n  amvers="-1.11"\nelif automake-1.10}, { :only_first_occurence => true }
          end
        end
        
        # The method fixes i2conf aclocal by removing aclocal option "-I m4".
        #
        def fix_i2conf_aclocal
          if Options.reveal or File.read(Path.i2conf_bootstrap).include?('-I m4')
            UI.info 'Fixing i2conf aclocal'.green.bold
            Cmd.replace Path.i2conf_bootstrap, '-I m4 ', ''
          end
        end
        
        # The method compiles i2conf with standard process and without any additional option setting.
        #
        def compile_i2conf
          UI.info 'Compiling i2conf'.green.bold
          Cmd.cd Path.i2conf, :internal => true
          Cmd.run './bootstrap'
          Cmd.run './configure'
          Cmd.run 'aclocal'
          Cmd.run 'make -j 15'
          Cmd.run 'sudo make install'
        end
        
        # This method creates desktop entry, so users can run MCU by clicking the i2conf icon in the Applications menu.
        # It copies the downloaded icon to pixmaps directory, so the icon can be shown at the gnome menu. 
        # It creates a .desktop file, fulfills the file with the constant DESKTOP_ENTRY, and substitutes the PLACEHOLDER with execution commands. 
        # Then, AI copies the .desktop file to /usr/share/applications directory and initiates the method of update_gnome_menu_cache to make all the
        # modifications take effect. It will also updates gnome menu cache after placing every file into the right place.
        #
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
        
        # The method creates a minimum configuration file for i2conf if it is not available.
        # This configuration is based on currently available carenet-se service. However, the user may modify the
        # configuration file according to its own network scenario after installation process.
        #
        def configure_i2conf
          if Path.i2conf_example_conf.file?
            UI.warn "Creating no example configuration file, because it already exists: #{Path.i2conf_example_conf}. "
          else
            UI.info "Creating example i2conf configuration file".green.bold
            Cmd.touch_and_replace_content Path.i2conf_example_conf, ::CSD::Application::I2conf::CONFIG_EXAMPLE
          end
        end
        
        # This method notifies users that i2conf installation process is completed successfully.
        # This notification will be shown on the top right of the desktop in Ubuntu system.
        # Users can then start i2conf by clicking the icon in gnome menu.
        #
        def send_notification
          Cmd.run %{notify-send --icon=i2conf_gnome "I2conf installation complete" "You are now ready to use your SIP MCU." }, :internal => true, :die_on_failure => false
        end
        
        # This method notifies users that i2conf installation process is completed successfully.
        # It is AI's internal notification, which will be shown on the command line interface.
        # Users can then start i2conf by clicking the icon in gnome menu or use command line interface.
        # AI will also notify the users about possible modifications on the configuration file, according to users' network scenario.
        # 
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
        
        # This method provides general introductions to users, like current working directory.
        # 
        # ====Options
        # [debug]  If debug option is set, users will be notified about system platform and current working module.
        # [help]   If help option is set, AI will provide all help information and cleanup in case the working directory was temporary and is empty.
        # [reveal] If reveal option is set, AI will continue and process the next method.
        # [yes]    If yes option is set, AI will continue and process the next method.
        # 
        # If users did not specify any option, AI will ask for their willingness to continue and process the next method 
        # after the users choose 'yes'. Or AI will terminate its operation.
        # 
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
        
        # This method is to define relative path in i2conf module. This will make the program clean and easy to read.
        #
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