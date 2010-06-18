require 'term/ansicolor'
#require 'active_support'

module StringExtensions
  
  def enquote
    "\"#{self}\""
  end
  
end

class String #:nodoc:
  include Term::ANSIColor
  include StringExtensions
end
