# -*- encoding: UTF-8 -*-
require 'csd/application/default'
require 'csd/application/graphics/error'
require 'csd/application/graphics/base'

module CSD
  module Application
    # This is the Application Module to update the graphics card drivers.
    #
    module Graphics
      class << self

        include CSD::Application::Default

        # This method will check which system we're on and initialize the correct sub-module
        #
        def instance
          if Gem::Platform.local.ubuntu?
            UI.debug "#{self}.instance finishes the system check"
            Base.new
          else
            raise 'Sorry, currently only Ubuntu is supported.'
          end
        end

      end
    end
  end
end
