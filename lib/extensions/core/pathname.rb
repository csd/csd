require File.join(File.dirname(__FILE__), 'string')

module Csd
  module Extensions
    module Core
      module Pathname
        
        def enquote
          to_s.enquote
        end
        
        def current_path?
          self.exist? and self.realpath == self.class.getwd.realpath
        end
      
      end
    end
  end
end

class Pathname #:nodoc:
  include Csd::Extensions::Core::Pathname
end
