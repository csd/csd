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
              case Gem::Platform.local.kernel_version
                when '#36-Ubuntu SMP Thu Jun 3 22:02:19 UTC 2010' then Ubuntu10.new
                else Debian.new
              end
            else
              Base.new
          end
        end
        
      end
    end
  end
end