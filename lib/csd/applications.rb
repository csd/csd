require 'ostruct'

module Csd
  
  # A class that provides meta-information about Applications
  #
  class ApplicationInfo < OpenStruct
  end
  
  # A convenience wrapper to get information about the available applications
  #
  class Applications
    
    # Returns the absolute path to the applications directory
    #
    def self.path
      Path.applications
    end
    
    def self.all(&block)
      Dir.directories(Path.applications) do |dir|
        begin
          app = ApplicationInfo.new(YAML.load_file(File.join(dir, 'about.yml')))
          app.dir_name = File.basename(dir)
          yield app
        rescue Errno::ENOENT => e
        end
      end
    end
    
  end
end