# -*- encoding: UTF-8 -*-

module CSD
  module Vendor
    # Author
    # 
    # Copyright (c) 2005-2010 David Heinemeier Hansson
    # This module is taken from Ruby on Rails' ActiveSupport
    # Link: http://github.com/rails/rails/tree/master/activesupport
    #
    # License
    # 
    # Active Support is released under the MIT license.
    #
    module ActiveSupport
      # This module comprises extensions to Object (the parent of all classes).
      #
      module ObjectExtensions
        
        # Makes backticks behave (somewhat more) similarly on all platforms.
        # On win32 `nonexistent_command` raises Errno::ENOENT; on Unix, the
        # spawned shell prints a message to stderr and sets $?.  We emulate
        # Unix on the former but not the latter.
        def `(command) #:nodoc:
          super
        rescue Errno::ENOENT => e
          STDERR.puts "#$0: #{e}"
        end
        
      end
    end
  end
end

class Object #:nodoc:
  include CSD::Vendor::ActiveSupport::ObjectExtensions
end