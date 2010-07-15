# encoding: utf-8
require 'term/ansicolor'
require 'csd/vendor/active_support/inflector'

module CSD
  module Extensions
    module Core
      module String
  
        def enquote
          %Q{"#{self}"}
        end
        
        def starts_with?(*args)
          start_with?(*args)
        end
        
        def ends_with?(*args)
          end_with?(*args)
        end
        
        def constantize
          Vendor::ActiveSupport::Inflector.constantize(self)
        end
        
        def camelize
          Vendor::ActiveSupport::Inflector.camelize(self)
        end
        
        def demodulize
          Vendor::ActiveSupport::Inflector.demodulize(self)
        end
        
        # Note that there is a conflict with +String.underscore+ created by +term/ansicolor+,
        # which is why this method is renamed to +underscorize+
        # 
        def underscorize
          Vendor::ActiveSupport::Inflector.underscore(self)
        end
        
      end
    end
  end
end

class String #:nodoc:
  include Term::ANSIColor
  include CSD::Extensions::Core::String
end
