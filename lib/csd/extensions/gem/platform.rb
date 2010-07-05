module CSD
  module Extensions
    module Gem
      module Platform
  
        def humanize
          version_string = version ? ", version #{version}" : ''
          "#{os} (CPU: #{cpu}#{version_string})"
        end
  
      end
    end
  end
end

module Gem
  class Platform #:nodoc:
    include CSD::Extensions::Gem::Platform
  end
end