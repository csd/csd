# -*- encoding: UTF-8 -*-
require 'ostruct'

module CSD
  class PathContainer < OpenStruct
    
    # This method chooses and holds the container for root privilege.
    #
    def root
      @root ||= Dir.pwd
    end
    
    # This method chooses and holds the container for gem.
    #
    def gem
      @gem ||= File.expand_path(File.join(File.dirname(__FILE__), '..' ,'..'))
    end
    
    # This method chooses and holds the container for vendor.
    #
    def vendor
      @vendor ||= File.join(self.gem, 'vendor')
    end
    
    # This method chooses and holds the container for applications.
    #
    def applications
      @applications ||= File.expand_path(File.join(self.gem, 'lib', 'csd', 'application'))
    end
    
  end
end