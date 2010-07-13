# encoding: utf-8
require 'term/ansicolor'

module CSD
  module Extensions
    module Core
      module String
  
        def enquote
          %Q{"#{self}"}
        end
        
      end
    end
  end
end

class String #:nodoc:
  include Term::ANSIColor
  include CSD::Extensions::Core::String
end
