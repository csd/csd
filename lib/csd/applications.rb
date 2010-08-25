# -*- encoding: UTF-8 -*-
require 'ostruct'
require 'csd/extensions/core/string'

module CSD
  
  # A convenience wrapper to get information about the available applications
  #
  class Applications
    
    # Returns the application module instance of +app_name+. Returns +nil+ if the application could not be found or loaded.
    #
    def self.find(app_name)
      return nil if app_name.to_s.empty?
      begin
        UI.debug "#{self}.find got a request to see whether `#{app_name}´ is a valid application or not"
        require File.join(Path.applications, app_name.to_s)
        UI.debug "#{self}.find tries to initialize the loaded application `#{app_name}´ now"
        "CSD::Application::#{app_name.to_s.camelize}".constantize
      rescue LoadError => e
        UI.debug "#{self}.find could not load `#{app_name}´ in #{e.to_s.gsub('no such file to load -- ', '').enquote}"
        nil
      end
    end
    
    # This method returns instantiated modules of all valid applications in an +Array+ or in a block.
    #
    def self.all(&block)
      result = []
      Dir.directories(Path.applications).sort.each do |dir|
        next if dir == 'default'
        if app = find(dir)
          block_given? ? yield(app) : result << app
        end
      end
      result
    end

    # This method holds the desired application and initializes its module into +@@current+.
    #
    def self.current
      # In testmode we don't want to perform caching
      return choose_current if Options.testmode
      # Otherwise we choose and cache the current application module here
      @@current ||= choose_current
    end
    
    # This method identifies the desired application. No caching takes place here.
    # It is meant to be very robust, we expect the application to be any one of the first three arguments.
    #
    def self.choose_current
      Applications.find(ARGV.first) || Applications.find(ARGV.second) || Applications.find(ARGV.third)
    end
    
  end
end