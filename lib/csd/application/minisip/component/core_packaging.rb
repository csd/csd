# -*- encoding: UTF-8 -*-

module CSD
  module Application
    module Minisip
      module Component
        module Core
          # This "outsourced" module is responsible for the packaging action. It would be too complex to
          # have this mixed with the installing logic.
          #
          module Packaging
            
            # Iteratively makes debian packages of the internal MiniSIP libraries.
            # TODO: Refactor this, it looks terribly sensitive.
            # TODO: Check for GPL and LGLP license conflicts.
            #
            def package
              UI.separator
              UI.info "This operation will make debian packages for all MiniSIP libraries.".green.bold
              UI.separator
              packing_introduction
              remove_ffmpeg
              Cmd.mkdir Path.packaging
              Cmd.mkdir Path.packages
              libraries.each do |library|
                @library = library
                @directory = Pathname.new(File.join(Path.repository, library))
                next if Options.only and !Options.only.include?(library)
                package!
              end
            end
            
            # This method is to provide general introductions to users, like current working directory.
            # Since MiniSIP need to be installed before packaging its core libraries, AI will first check whether MiniSIP
            # has been compiled in the current working directory, if it is not, AI will raise an error and notify users to
            # to install MiniSIP before packaging, other wise, AI will continue with its operation.
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
            def packing_introduction
              UI.info " Working directory:       ".green.bold + Path.work.to_s.yellow
              unless Path.repository.directory?
                UI.warn "#{::CSD.executable} install minisip --no-temp"
                raise Error::Minisip::Core::PackagingNeedsInstalledMinisip,"Please install MiniSIP by AI, before creating its Debain packages. "
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
            
            # The method initiates corresponding method to package MiniSIP core libraries. The reason of doing that
            # is to keep the source code clean and easy to read.
            #
            def package!
              make_dist
              extract_tar_file
              build_package
            end
            
            # 
            def make_dist
              UI.info "Making #{@library} with target dist".green.bold
              Cmd.cd(@directory) or Options.reveal
              Cmd.run("make dist")
              @tar_filename = File.basename(Dir[File.join(@directory, '*.tar.gz')].first)
              Cmd.move(File.join(@directory, @tar_filename.to_s), Path.packaging) if @tar_filename or Options.reveal
            end
            
            def extract_tar_file
              Cmd.cd(Path.packaging) or Options.reveal
              Cmd.run("tar -xzf #{@tar_filename}")
              @tar_dirname = File.basename(@tar_filename.to_s, '.tar.gz')
            end
              
            def build_package
              Cmd.cd(File.join(Path.packaging, @tar_dirname))
              Cmd.run("dpkg-buildpackage -rfakeroot")
              if @library == 'minisip'
                if Cmd.cd(Path.packaging)
                  package = File.basename(Dir[File.join(Path.packaging, "#{@library}*.deb")].first)
                  Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                  Cmd.move(File.join(Path.packaging, package.to_s), Path.packages) if package or Options.reveal
                end
              else
                if Cmd.cd(Path.packaging)
                  package = File.basename(Dir[File.join(Path.packaging, "#{@library}0*.deb")].first)
                  Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                  Cmd.move(File.join(Path.packaging, package.to_s), Path.packages) if package or Options.reveal
                  dev_package = File.basename(Dir[File.join(Path.packaging, "#{@library}-dev*.deb")].first)
                  Cmd.run("sudo dpkg -i #{dev_package}") if dev_package or Options.reveal
                  Cmd.move(File.join(Path.packaging, dev_package.to_s), Path.packages) if dev_package or Options.reveal
                end
              end
            end
            
          end
        end
      end
    end
  end
end
