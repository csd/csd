module Csd
  module Extensions
    module Core
      module Object
        
        # Creates a Pathname object from the current object. Preferrably from Strings and Hashes.
        #
        def pathnamify
          case self
            when ::Pathname then self
            else ::Pathname.new(self)
          end
        end
        
      end
    end
  end
end

class Object #:nodoc:
  include Csd::Extensions::Core::Object
end
