require 'ostruct'

module Csd
  class Path
    
    def self.root
      ROOT_PATH
    end
    
    def self.applications
      File.expand_path(File.join(root, 'lib', 'csd', 'applications'))
    end
    
  end
end