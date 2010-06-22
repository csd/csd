require File.join(File.dirname(__FILE__), 'string')
require 'optparse'

module Csd
  module Extensions
    module Core
      module OptionParser

        def newline
          separator ''
        end
          
        def headline(text)
          newline
          separator(text)
        end
        
        def subheadline(text)
          separator(@summary_indent + text)
        end
        
        def list_item(item, description, &block)
          separator(summary_indent + item.ljust(summary_width + 1) + description)
        end
        
      end
    end
  end
end

class OptionParser #:nodoc:
  include Csd::Extensions::Core::OptionParser
end
