# -*- encoding: UTF-8 -*-
require 'csd/application/default'
require 'csd/application/decklink/base'

module CSD
  module Application
    # This is the Application Module for Decklink, a capture card device used in MiniSIP.
    #
    module Decklink
      class << self

        include CSD::Application::Default

        # This method will check which system we're on and initialize the correct sub-module
        #
        def instance
          if Gem::Platform.local.debian?
            Base.new
          else
            raise 'Operating system not supported'
          end
        end

      end
    end
  end
end
