# -*- encoding: UTF-8 -*-
require 'ostruct'
require 'csd/application/default'
require 'csd/application/minisip/error'
require 'csd/application/minisip/base'
require 'csd/application/minisip/unix/linux/debian/ubuntu10'

module CSD
  module Application
    module Minisip
      class << self

        include CSD::Application::Default

        def instance
          @instance ||= case Gem::Platform.local.os
            when 'linux'
              UI.debug "Analyzing kernel release: #{Gem::Platform.local.kernel_release}"
              case Gem::Platform.local.kernel_release
                when /2.6.32-2(1|2)-generic/
                  UI.debug "Ubuntu 10.04 identified"
                  Ubuntu10.new
                else
                  UI.debug "Debian identified"
                  Debian.new
              end
            else
              UI.debug "Nothing identified"
              Base.new
          end
        end
        
      end
    end
  end
end