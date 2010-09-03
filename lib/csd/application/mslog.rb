# -*- encoding: UTF-8 -*-
require 'csd/application/default'
require 'csd/application/mslog/base'

module CSD
  module Application
    # This is the Application Module to install MiniSIP logging server.
    #
    module Mslog
      class << self

        include CSD::Application::Default

        # This method will check which system we're on and initialize the correct sub-module.
        # Currently we only support Ubuntu.
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
