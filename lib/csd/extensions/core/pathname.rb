# -*- encoding: UTF-8 -*-
require 'csd/extensions/core/string'

module CSD
  module Extensions
    module Core
      # This module comprises extensions to Pathname objects.
      #
      module Pathname
        
        # This method returns the full paths to all children-directories (i.e. first generation of descendants)
        # of a directory in either an +Array+, or in a block.
        #
        # ==== Examples
        #
        #  Dir.directories('/home/user')    # => ['/home/user/Desktop', '/home/user/Documents', ...]
        #
        #  Dir.directories('/home/user') do |dir|
        #    puts dir
        #  end
        #
        def children_directories(&block)
          result = []
          children.map do |child|
            next unless child.directory?
            block_given? ? yield(child) : result << child
          end
          result
        end
        
        # Converts a Pathname object into a +String+ and wraps it into two quotation
        # marks (according to the +String#enquite+ method). This method is useful for
        # printing a path in a readable way in a command-line user interface.
        #
        def enquote
          to_s.enquote
        end
        
        # Verifies whether the current directory (i.e. +pwd+) is the path of this Pathname
        # object. Returns +true+ or +false+.
        #
        # ==== Examples
        #
        #  Dir.chdir('/home/user')
        #  Pathname.new('/home/user').current_path?            # => true
        #  Pathname.new('/home/user/../user').current_path?    # => true
        #  Pathname.new('/lib').current_path?                  # => false
        #  Pathname.new('/i/do/not/exist').current_path?       # => false
        #
        def current_path?
          self.exist? and self.realpath == self.class.getwd.realpath
        end
      
      end
    end
  end
end

class Pathname #:nodoc:
  include CSD::Extensions::Core::Pathname
end
