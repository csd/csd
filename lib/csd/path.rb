module CSD
  class Path < GlobalOpenStruct
      
    def self.root
      @@root ||= File.expand_path(File.join(File.dirname(__FILE__), '..' ,'..'))
    end
    
    def self.applications
      @@applications ||= File.expand_path(File.join(root, 'lib', 'csd', 'application'))
    end
    
    def self.applications=(path)
      @@applications = File.expand_path(path)
    end
    
  end
end