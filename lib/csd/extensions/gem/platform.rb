# encoding: utf-8

module CSD
  module Extensions
    module Gem
      module Platform
  
        def humanize
          version_string = version ? ", version #{version}" : ''
          "#{os} (CPU: #{cpu}#{version_string})"
        end
        
        def kernel_version
          Cmd.run('uname --kernel-version', :show_output => false).chop if os == 'linux'
        end
        
        def kernel_release
          Cmd.run('uname --kernel-release', :show_output => false).chop if os == 'linux'
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