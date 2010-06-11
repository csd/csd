require File.join(File.dirname(__FILE__), '..', 'base')

module CSD
  module Application
    module Minisip
      class Minisip < CSD::Application::Base
                
        def introduction
          super
          log
          log "Hello, I'm the application #{self.class.name}"
          exit unless ask_yes_no("Continue?", true)
          build!
        end
        
        def build!
          define_paths
          create_working_dir
          checkout_repository
          make_libraries
        end

        def define_paths
          path.work       = File.expand_path(File.join(path.root, 'minisip_building'))
          path.repository = File.expand_path(File.join(path.work, 'repository'))
        end
        
        def create_working_dir
          if File.directory?(path.work)
            log "Working directory ´#{path.work}´ already exists."
          else
            log "Creating working directory ´#{path.work}´"
            Dir.mkdir(path.work)
          end
          Dir.chdir(path.work)
        end
        
        def checkout_repository
          if File.directory?(path.repository)
            log "The minisip repository already exists in ´#{path.repository}´"
          else
            log "Checking out minisip repository to ´#{path.repository}´"
            #run_command("git clone http://github.com/csd/minisip.git repository")
            if test_command('svn', 'info', 'svn://minisip.org/minisip/trunk')
              run_command("svn co svn://minisip.org/minisip/trunk #{path.repository}")
            else
              log "Sorry, something is wrong with subversion.".red.bold
              exit
            end
          end
        end
        
        def make_libraries
          ['libmutil', 'libmnetutil', 'libmcrypto', 'libmikey', 'libmsip', 'libmstun', 'libminisip'].each do |lib|
            lib_dir = File.join(path.repository, lib)
            if File.directory?(lib_dir)
              Dir.chdir(lib_dir)
              log "Bootstrapping #{lib}".green.bold
              run_command("./bootstrap")
              log "Configuring #{lib}".green.bold
              run_command("./configure")
              log "Make #{lib}".green.bold
              run_command("make")
              log "Make install #{lib}".green.bold
              #run_command("make install")
            else
              log "Skipping ´#{lib}´ because ´#{lib_dir}´ could not be found".red.bold
            end
          end
        end
        
      end
    end
  end
end