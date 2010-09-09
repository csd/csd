# -*- encoding: UTF-8 -*-
require 'digest/sha1'
require 'csd/vendor/term/ansicolor'
require 'csd/vendor/active_support/inflector'

module CSD
  module Extensions
    module Core
      # This module comprises extensions to String objects.
      #
      module String
        
        # Adds a double-quote to the beginning and the end of a +String+.
        #
        # ==== Example
        #
        #   'Hello World'.enquote    # => '`Hello World´'
        #
        def enquote
          %Q{"#{self}"}
        end
        
        # Creates a SHA1 hash of the String object.
        #
        def hashed
          Digest::SHA1.hexdigest self
        end
        
        # See CSD::Vendor::ActiveSupport::Inflector#constantize
        #
        def constantize
          Vendor::ActiveSupport::Inflector.constantize(self)
        end
        
        # See CSD::Vendor::ActiveSupport::Inflector#camelize
        #
        def camelize
          Vendor::ActiveSupport::Inflector.camelize(self)
        end
        
        # See CSD::Vendor::ActiveSupport::Inflector#demodulize
        #
        def demodulize
          Vendor::ActiveSupport::Inflector.demodulize(self)
        end
        
        # See CSD::Vendor::ActiveSupport::Inflector#underscore. Note that there is
        # a name conflict with <tt>String#underscore</tt> provided by CSD::Vendor::Term::ANSIColor,
        # which is why this method is renamed to +underscorize+.
        # 
        def underscorize
          Vendor::ActiveSupport::Inflector.underscore(self)
        end
        
        # Just an alias to the more logical wording of this method
        #
        def starts_with?(*args) #:nodoc:
          start_with?(*args)
        end
        
        # Just an alias to the more logical wording of this method
        #
        def ends_with?(*args) #:nodoc:
          end_with?(*args)
        end
        
      end
    end
  end
end

class String #:nodoc:
  include CSD::Vendor::Term::ANSIColor
  include CSD::Extensions::Core::String
end
