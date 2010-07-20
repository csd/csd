# -*- encoding: UTF-8 -*-
require 'csd/extensions/core/string'
require 'optparse'

module CSD
  module Extensions
    module Core
      # This module comprises extensions to OptionParser objects.
      #
      module OptionParser

        # Inserts a new line to the options help output.
        #
        def newline
          separator ''
        end
          
        # Inserts a new line and a headline to the options help output.
        #
        def headline(text)
          newline
          separator(text)
        end
        
        # Inserts an indented headline to the options help output.
        #
        def subheadline(text)
          separator(@summary_indent + text)
        end
        
        # This method creates a line with two columns. The +item+ will be in the first
        # column and be indented. The +description+ will be in the second column.
        #
        # ==== Examples
        #
        #  OptionParser.new do |opts|
        #    opts.headline 'List of Applications'
        #    opts.list_item 'MiniSIP', 'An open-source high-definition video conferencing client.'
        #    opts.list_item 'OpenSIP', 'An open-source SIP server.'
        # end
        #
        def list_item(item='', description='')
          separator(summary_indent + item.ljust(summary_width + 1) + description)
        end
        
      end
    end
  end
end

class OptionParser #:nodoc:
  include CSD::Extensions::Core::OptionParser
end
