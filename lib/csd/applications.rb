require 'ostruct'

module CSD
  
  # A convenience wrapper to get information about the available applications
  #
  class Applications

    # Returns nil if application could not be found
    #
    def self.find(app_name)
      begin
        require File.join(Path.applications, app_name)
        "CSD::Application::#{app_name.camelize}".constantize
      rescue MissingSourceFile
        UI.debug "The Application `#{app_name}´ could not be loaded properly."
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
      @@current ||= Applications.find(ARGV.second) if ARGV.second and !ARGV.first.starts_with?('-')
    end
    
  end
end