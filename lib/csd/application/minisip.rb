# encoding: utf-8
require 'ostruct'
require File.join(File.dirname(__FILE__), 'default')
require File.join(File.dirname(__FILE__), 'minisip', 'error')
require File.join(File.dirname(__FILE__), 'minisip', 'base')
require File.join(File.dirname(__FILE__), 'minisip', 'unix', 'linux', 'debian', 'ubuntu10')

module CSD
  module Application
    module Minisip
      class << self

        include CSD::Application::Default

        def instance
          @instance ||= case Gem::Platform.local.os
            when 'linux'
              UI.debug "Analyzing kernel version: #{Gem::Platform.local.kernel_version}"
              case Gem::Platform.local.kernel_version
                when /(36-Ubuntu)|(37-Ubuntu)/
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