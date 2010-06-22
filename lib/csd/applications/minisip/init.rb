Dir.glob(File.join(File.dirname(__FILE__), '**', '*.rb')) { |file| require file }

module Csd
  module Application
    module Minisip
      class Init
                
        def self.application(*args)
          case Gem::Platform.local.os
            when 'linux'
              Unix::Base.new(*args)
            else
              Base.new(*args)
          end
        end
        
      end
    end
  end
end