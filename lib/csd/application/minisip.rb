require File.join(File.dirname(__FILE__), 'default')
Dir.glob(File.join(File.dirname(__FILE__), 'minisip', '*.rb')) { |file| require file }
Dir.glob(File.join(File.dirname(__FILE__), 'minisip', 'unix', '*.rb')) { |file| require file }
require 'ostruct'

module CSD
  module Application
    module Minisip
      class << self
        
        include CSD::Application::Default
        
        def instance
          @instance ||= case Gem::Platform.local.os
            when 'linux'
              Unix::Base.new
            else
              Base.new
          end
        end
        
      end
    end
  end
end