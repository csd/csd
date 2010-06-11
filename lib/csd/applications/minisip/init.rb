require File.join(File.dirname(__FILE__), 'minisip')
Dir.glob(File.join(File.dirname(__FILE__), '**', '*.rb')) { |file| require file }

module CSD
  module Application
    module Minisip
      class Init
                
        def self.application(*args)
          case Gem::Platform.local
            when 'linux'
              MinisipLinux.new(*args)
            when 'darwin'
              MinisipDarwin.new(*args)
            else
              Minisip.new(*args)
          end
        end
        
      end
    end
  end
end