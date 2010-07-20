# -*- encoding: UTF-8 -*-

module CSD
  # This namespace is given to modifications to the ruby language or other gems. Its purpose is to
  # simplify working with simple objects, such as Arrays, Files, etc.
  #
  module Extensions
    # This namespace is given to all extensions made to the Ruby Core or the Ruby Standard Library.
    #
    module Core
      # This module comprises extensions to the Array object.
      #
      module Array

        # Equal to <tt>self[1]</tt>.
        def second
          self[1]
        end

        # Equal to <tt>self[2]</tt>.
        def third
          self[2]
        end

        # Equal to <tt>self[3]</tt>.
        def fourth
          self[3]
        end

        # Equal to <tt>self[4]</tt>.
        def fifth
          self[4]
        end

      end
    end
  end
end

class Array #:nodoc:
  include CSD::Extensions::Core::Array
end
