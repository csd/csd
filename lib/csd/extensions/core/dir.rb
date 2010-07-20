# -*- encoding: UTF-8 -*-
require 'pathname'

module CSD
  module Extensions
    module Core
      # This module comprises extensions to the Dir object.
      #
      module Dir
        
        # This method returns the names of all children-directories (i.e. first generation of descendants)
        # of a directory in either an +Array+, or in a block. It does the same thing as
        # +Pathname.children_directories+ but returns just the name and not the entire path to the children directories.
        #
        # ==== Examples
        #
        #  Dir.directories('/home/user')    # => ['Desktop', 'Documents', ...]
        #
        #  Dir.directories('/home/user') do |dir|
        #    puts dir
        #  end
        #
        def directories(path, &block)
          if block_given?
            ::Pathname.new(path).children_directories { |pathname| yield pathname.basename.to_s }
          else
            ::Pathname.new(path).children_directories.map { |pathname| pathname.basename.to_s }
          end
        end
        
      end
    end
  end
end

class Dir #:nodoc:
  extend CSD::Extensions::Core::Dir
end
