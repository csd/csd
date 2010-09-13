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
              Cmd.mkdir Path.packaging
              libraries.each do |library|
              directory = Pathname.new(File.join(Path.repository, library))
              next if Options.only and !Options.only.include?(library)
              package!
            end
            
            def packing_introduction
              UI.info " MiniSIP".green.bold
              # If the repository directory already exists, we indicate that here
              download_text = Path.repository.directory? ? "  - located at:           " : "  - downloading to:       "
              UI.info download_text.green + Path.repository.to_s.yellow
              # Now let's present which libraries will be compiled with which commands
              UI.info "  - libraries to process: ".green + libraries.join(', ').yellow
            end
            
            def package!
              make_dist
              extract_tar_file
              build_package
            end
            
            def make_dist
              UI.info "Making #{library} with target dist".green.bold
              Cmd.cd(directory) or Options.reveal
              Cmd.cd 
              Cmd.run("make dist")
              tar_filename = File.basename(Dir[File.join(directory, '*.tar.gz')].first)
              Cmd.move(File.join(directory, tar_filename.to_s), Path.packaging) if tar_filename or Options.reveal
            end
            
            def extract_tar_file
              Cmd.cd(Path.packaging) or Options.reveal
              Cmd.run("tar -xzf #{tar_filename}")
              tar_dirname = File.basename(tar_filename.to_s, '.tar.gz')
            end
              
            def build_package
              Cmd.cd(File.join(Path.packaging, tar_dirname))
              Cmd.run("dpkg-buildpackage -rfakeroot")
              if library == 'minisip'
                if Cmd.cd(Path.packaging)
                     package = File.basename(Dir[File.join(Path.packaging, "#{library}*.deb")].first)
                     Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                end
              else
                 if Cmd.cd(Path.packaging)
                      package = File.basename(Dir[File.join(Path.packaging, "#{library}0*.deb")].first)
                      Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                      dev_package = File.basename(Dir[File.join(Path.packaging, "#{library}-dev*.deb")].first)
                      Cmd.run("sudo dpkg -i #{dev_package}") if dev_package or Options.reveal
                 end
               end
            end
              
              
              
              
              
=begin
            def package!
              Cmd.mkdir Path.packaging
              libraries.each do |library|
                directory = Pathname.new(File.join(Path.repository, library))
                next if Options.only and !Options.only.include?(library)
                UI.info "Making #{library} with target dist".green.bold
                if Cmd.cd(directory) or Options.reveal
                  Cmd.run("make dist")
                  
                  tar_filename = File.basename(Dir[File.join(directory, '*.tar.gz')].first)
                  Cmd.move(File.join(directory, tar_filename.to_s), Path.packaging) if tar_filename or Options.reveal
                  
                  if Cmd.cd(Path.packaging) or Options.reveal
                    Cmd.run("tar -xzf #{tar_filename}")
                    tar_dirname = File.basename(tar_filename.to_s, '.tar.gz')
                    if Cmd.cd(File.join(Path.packaging, tar_dirname))
                      Cmd.run("dpkg-buildpackage -rfakeroot")
                      if library == 'minisip'
                        if Cmd.cd(Path.packaging)
                          package = File.basename(Dir[File.join(Path.packaging, "#{library}*.deb")].first)
                          Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                        end
                      else
                        if Cmd.cd(Path.packaging)
                          package = File.basename(Dir[File.join(Path.packaging, "#{library}0*.deb")].first)
                          Cmd.run("sudo dpkg -i #{package}") if package or Options.reveal
                          dev_package = File.basename(Dir[File.join(Path.packaging, "#{library}-dev*.deb")].first)
                          Cmd.run("sudo dpkg -i #{dev_package}") if dev_package or Options.reveal
                        end
                      end
                    else
                      UI.error "Could not enter #{File.join(Path.packaging, tar_dirname)}."
                    end
                    
                  else
                    UI.error "Could not enter #{Path.packaging}."
                  end
                  
                else
                  UI.error "Could not enter #{directory}."
                end
              end
            end
            
          end
        end
      end
    end
  end
end

=end