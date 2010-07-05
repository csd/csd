require 'ostruct'

module CSD
  
  # A convenience wrapper to get information about the available applications
  #
  class Applications

    # Returns nil if application could not be found
    #
    def self.find(dir_name)
      begin
        require File.join(Path.applications, dir_name)
        "CSD::Application::#{dir_name.camelize}".constantize
      rescue MissingSourceFile
        nil
      end
    end

    def self.all(&block)
      result = []
      Dir.directories(Path.applications) do |dir|
        if app = find(dir)
          block_given? ? yield(app) : result << app
        end
      end
      result
    end

    def self.valid?(name)
      list.include?(name)
    end
    
    def self.current
      @@current
    end
    
    def self.current=(name)
      @@current = name
    end
    
  end
end