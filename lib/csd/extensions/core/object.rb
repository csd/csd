# -*- encoding: UTF-8 -*-
require 'csd/vendor/active_support/object_extensions'

module CSD
  module Extensions
    module Core
      # This module comprises extensions to Object (the parent of all classes).
      #
      module Object
        
        # Creates a Pathname object from the current object.
        #
        # ==== Examples
        #
        #  '/my/path'.pathnamify            # =>  #<Pathname:my/path>
        #  my_pathname_object.pathnamify    # =>  #<Pathname:my/path>
        #
        def pathnamify
          case self
            when ::Pathname then self
            when NilClass then raise ::CSD::Error::Internal::PathnamifyingNil
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
