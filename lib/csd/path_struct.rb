require 'ostruct'

module CSD
  class PathStruct < OpenStruct
    
    def gem_root
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    end
    
    def applications
      File.expand_path(File.join(gem_root, 'lib', 'csd', 'applications'))
    end
  
  end
end