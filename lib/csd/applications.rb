require 'ostruct'
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module CSD
  
  # A convenience wrapper to get information about the available applications
  #
  class Applications

    # Returns nil if application could not be found
    #
    def self.find(app_name)
      begin
        require File.join(Path.applications, app_name.to_s)
        ActiveSupport::Inflector.constantize "CSD::Application::#{app_name.camelize}"
      rescue LoadError
        UI.debug "The Application `#{app_name}´ could not be loaded properly."
        nil
      end
    end

    def self.all(&block)
      result = []
      Dir.directories(Path.applications) do |dir|
        next if dir == 'default'
        if app = find(dir)
          block_given? ? yield(app) : result << app
        end
      end
      result
    end

    def self.valid?(name)
      list.include?(name)
    end
    
    # This method identifies the desired application and initializes it in to +@@current+.
    # It is meant to be very robust, we expect the application to be any one of the first three arguments.
    #
    def self.current
      @@current ||= begin
        Applications.find(ARGV.first) || Applications.find(ARGV.second) || Applications.find(ARGV.third)
      end
    end
    
    # Forces a reload of the current application. This method is useful for functional tests.
    #
    def self.current!
      @@current = false
      current
    end
    
  end
end