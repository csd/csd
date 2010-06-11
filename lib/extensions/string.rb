require 'term/ansicolor'
#require 'active_support'

module StringExtensions
  
  #def constantize
  #  ActiveSupport::Inflector.constantize(self)
  #end
  
end

class String #:nodoc:
  include Term::ANSIColor
  include StringExtensions
end
