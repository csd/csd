module CSD
  class Minisip
    
    include Shared
    
    def initialize(options={})
      @options = options[:options]

      unless Gem::Platform.local.os == 'linux'
        puts "Sorry, Linux only at the moment"
        exit 1
      end
      
      unless File.directory?('minisip')
        log "Creating directory minisip"
        Dir.mkdir('minisip')
      end
      
      Dir.chdir('minisip')
      root_dir = Dir.pwd
      
      ['git-core', 'automake', 'libssl-dev', 'libtool', 'libglademm-2.4-dev'].each do |apt|
        run_command("sudo apt-get install #{apt}")
      end
      
      unless File.directory?('repository')
        log "Checking out minisip repository"
        checkout_repository
      end
      
      run_command "sudo echo /usr/local/share/aclocal >> /usr/share/aclocal/dirlist"
      
      ['libmutil', 'libmnetutil', 'libmcrypto', 'libmikey', 'libmsip', 'libmstun', 'libminisip'].each do |lib|
        Dir.chdir File.join(root_dir, 'repository', lib)
        log "Going through #{Dir.pwd}"
      end
      
    end
    
    def checkout_repository
      run_command("git clone http://github.com/csd/minisip.git repository")
    end
    
  end
  
  
end