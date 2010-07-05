module CSD
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
  include CSD::Extensions::Core::Object
end
