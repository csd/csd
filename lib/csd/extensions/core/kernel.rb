# -*- encoding: UTF-8 -*-

module CSD
  module Extensions
    module Core
      # This module comprises extensions to the Kernel module
      #
      module Kernel
        
        # Checks whether the AI was executed with superuser rights (a.k.a. +sudo+). Returns +true+ or +false+.
        #
        def superuser?
          Process.uid == 0
        end
        
      end
    end
  end
end

module Kernel #:nodoc:
  include CSD::Extensions::Core::Kernel
end
