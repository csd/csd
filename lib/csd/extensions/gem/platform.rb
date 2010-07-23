# -*- encoding: UTF-8 -*-

module CSD
  module Extensions
    # This namespace is given to all extensions made to third-party Gems.
    #
    module Gem
      # This module comprises extensions to the Array object.
      #
      module Platform
  
        # This method returns a human-readable string for the current OS and CPU architecture.
        #
        def humanize
          version_string = version ? ", version #{version}" : ''
          "#{os} (#{cpu}#{version_string})"
        end
        
        # On linux systems, this method returns the current kernel version.
        #
        def kernel_version
          Cmd.run('uname --kernel-version', :internal => true).output.to_s.chop if os == 'linux'
        end
        
        # On linux systems, this method returns the current kernel release.
        #
        def kernel_release
          Cmd.run('uname --kernel-release', :internal => true).output.to_s.chop if os == 'linux'
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