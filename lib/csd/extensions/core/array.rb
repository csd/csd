# -*- encoding: UTF-8 -*-

module CSD
  module Extensions
    module Core
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
