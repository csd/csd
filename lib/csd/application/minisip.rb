require File.join(File.dirname(__FILE__), 'minisip', 'errors')
Dir.glob(File.join(File.dirname(__FILE__), 'minisip', 'unix', '*.rb')) { |file| require file }

module CSD
  module Application
    module Minisip
      class << self
                
        def bootstrap(*args)
          case Gem::Platform.local.os
            when 'linux'
              Unix::Base.new(*args)
            else
              Base.new(*args)
          end
        end
        
        def name
          'minisip'
        end
        
        def description
          'An open-source SIP client for high-definition video conferencing'
        end
        
        def human
          'MiniSIP'
        end
        
        def option_parser
          File.read(File.join(File.dirname(__FILE__), 'minisip', 'options.rb'))
        end
        
      end
    end
  end
end