# -*- encoding: UTF-8 -*-
require 'csd/application/default'
require 'csd/application/i2conf/base'

module CSD
  module Application
    # This is the Application Module for i2conf, a sip video conference MCU.
    #
    module I2conf
      class << self

        include CSD::Application::Default

        # This method will check which system we're on and initialize the correct sub-module
        #
        def instance
          if Gem::Platform.local.ubuntu?
            UI.debug "#{self}.instance initializes the i2conf Base class now"
            Base.new
          else
            raise 'Sorry, currently only Ubuntu is supported.'
          end
        end

      end
    end
  end
end
