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
        run_command("sudo apt-get --yes install #{apt}")
      end
      
      unless File.directory?('repository')
        log "Checking out minisip repository"
        checkout_repository
      end
      
      run_command "sudo echo /usr/local/share/aclocal >> /usr/share/aclocal/dirlist"
      
      ['libmutil', 'libmnetutil', 'libmcrypto', 'libmikey', 'libmsip', 'libmstun', 'libminisip'].each do |lib|
        Dir.chdir File.join(root_dir, 'repository', lib)
        log "Going through #{Dir.pwd}"
        run_command("./bootstrap")
        run_command("./configure")
        run_command("make")
        run_command("make install")
      end
      
      run_command("ldconfig /usr/local/lib/libminisip.so.0")
      run_command("minisip_gtkgui")
      
    end
    
    def checkout_repository
      run_command("git clone http://github.com/csd/minisip.git repository")
    end
    
  end
  
  
end