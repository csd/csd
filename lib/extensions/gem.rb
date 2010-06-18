module Gem
  module PlatformExtensions
  
    def humanize
      version_string = version ? ", version #{version}" : ''
      "#{os} (CPU: #{cpu}#{version_string})"
    end
  
  end
end

module Gem
  class Platform #:nodoc:
    include PlatformExtensions
  end
end