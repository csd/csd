require 'term/ansicolor'

module Csd
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
  include Csd::Extensions::Core::String
end
