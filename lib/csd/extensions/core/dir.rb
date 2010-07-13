# encoding: utf-8
require 'pathname'

module CSD
  module Extensions
    module Core
      module Dir
        
        def directories(path, &block)
          if block_given?
            ::Pathname.new(path).children_directories { |pathname| yield pathname.basename.to_s }
          else
            ::Pathname.new(path).children_directories.map { |pathname| pathname.basename.to_s }
          end
        end
        
        # Returns all direct subdirectories of +path+ with their entire path
        #
        #def directories(path, &block)
        #  result = []
        #  glob(::File.join(path, '*')).each do |dir|
        #    if (::File.directory?(dir) and dir != '.' and dir != '..')
        #      block_given? ? yield(dir) : result << dir
        #    end
        #  end
        #  result
        #end
        
        #def directories(path, absolute=false, &block)
        #  result = []
        #  entries(path) do |entry|
        #    if (::File.directory?(entry) and entry != '.' and entry != '..')
        #      dir = absolute? ? File.join(path, entry) : entry
        #      block_given? ? yield(dir) : result << dir
        #    end
        #  end
        #  result
        #end
        
      end
    end
  end
end

class Dir #:nodoc:
  extend CSD::Extensions::Core::Dir
end
