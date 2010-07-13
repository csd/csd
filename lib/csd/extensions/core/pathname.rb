# encoding: utf-8
require File.join(File.dirname(__FILE__), 'string')

module CSD
  module Extensions
    module Core
      module Pathname
        
        def children_directories(&block)
          result = []
          children.map do |child|
            next unless child.directory?
            block_given? ? yield(child) : result << child
          end
          result
        end
        
        def enquote
          to_s.enquote
        end
        
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
