# -*- encoding: UTF-8 -*-
require 'ostruct'

module CSD
  module Extensions
    module Core
      # This module comprises extensions to OpenStruct.
      #
      module OpenStruct
        
        # Deletes all attributes of this OpenStruct instance.
        #
        def clear
          testmode = self.testmode # This is the only thing we would not like to overwrite. It indicates whether we are running our Test Suite or not.
          @table = {}
          self.testmode = testmode
        end
        
      end
    end
  end
end

class Object #:nodoc:
  include CSD::Extensions::Core::OpenStruct
end
