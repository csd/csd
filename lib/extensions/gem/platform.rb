module Csd
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
    include Csd::Extensions::Gem::Platform
  end
end