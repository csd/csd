# encoding: utf-8
require 'ostruct'

module CSD
  class PathContainer < OpenStruct
    
    def root
      @root ||= Dir.pwd
    end
    
    def gem
      @gem ||= File.expand_path(File.join(File.dirname(__FILE__), '..' ,'..'))
    end
    
    def vendor
      @vendor ||= File.join(self.gem, 'vendor')
    end
    
    def applications
      @applications ||= File.expand_path(File.join(self.gem, 'lib', 'csd', 'application'))
    end
    
  end
end