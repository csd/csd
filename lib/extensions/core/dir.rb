module Csd
  module Extensions
    module Core
      module Dir
        
        def directories(path, &block)
          glob(::File.join(path, '*')).each { |dir| yield dir if (::File.directory?(dir) and dir != '.' and dir != '..') }
        end
        
      end
    end
  end
end

class Dir #:nodoc:
  extend Csd::Extensions::Core::Dir
end
