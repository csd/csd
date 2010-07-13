# encoding: utf-8
require File.join(File.dirname(__FILE__), 'global_open_struct')

module CSD
  class Path < GlobalOpenStruct
    
    def self.root
      @@root ||= Dir.pwd
    end
    
    def self.root=(path)
      @@root = path
    end
    
    def self.gem
      @@gem ||= File.expand_path(File.join(File.dirname(__FILE__), '..' ,'..'))
    end
    
    def self.vendor
      @@vendor ||= File.join(gem, 'vendor')
    end
    
    def self.applications
      @@applications ||= File.expand_path(File.join(gem, 'lib', 'csd', 'application'))
    end
    
    def self.applications=(path)
      @@applications = File.expand_path(path)
    end
    
  end
end