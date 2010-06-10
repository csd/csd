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
      ['git-core', 'automake', 'libssl-dev', 'libtool', 'libglademm-2.4-dev'].each do |apt|
        run_command("sudo apt-get install #{apt}")
      end
      unless File.directory?('trunk')
        log "Checking out minisip trunk"
        checkout_trunk
      end
      
      
    end
    
    def checkout_trunk
      run_command("git clone http://github.com/csd/minisip")
    end
    
  end
  
  
end