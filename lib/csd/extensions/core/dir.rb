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
        
      end
    end
  end
end

class Dir #:nodoc:
  extend CSD::Extensions::Core::Dir
end
