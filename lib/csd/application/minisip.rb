# -*- encoding: UTF-8 -*-
require 'ostruct'
require 'csd/application/default'
require 'csd/application/minisip/error'
require 'csd/application/minisip/base'
require 'csd/application/minisip/unix'
require 'csd/application/minisip/unix/darwin'
require 'csd/application/minisip/unix/linux'
require 'csd/application/minisip/unix/linux/debian'
require 'csd/application/minisip/unix/linux/debian/ubuntu10'

module CSD
  module Application
    # This is the Application Module for MiniSIP, an open-source high-definition video conferencing client.
    #
    module Minisip
      class << self

        include CSD::Application::Default

        # This method will check which operating system we're on and initialize the correct sub-module
        # (see http://github.com/rubygems/rubygems/blob/master/lib/rubygems/platform.rb#L65 for supported
        # platform identifiers).
        #
        # Currently these platforms can generally exist: 
        # * +cygwin+ (a Linux-like environment for Windows)
        # * +darwin+ (Mac OS X)
        # * +freebsd+
        # * +hpux+ (Hewlett Packard UniX)
        # * +java+
        # * +dotnet+
        # * +linux+ (Debian, OpenSUSE, Ubuntu, Red Hat, Fedora...)
        # * +mingw32+ (Minimalist GNU for Windows)
        # * +mswin*+ (Microsoft Windows, e.g. +mswin32+, +mswin64+)
        # * +netbsdelf+
        # * +openbsd+
        # * +solaris+
        # * +unknown+
        #
        def instance
          @instance ||= case Gem::Platform.local.os
            
            when 'darwin'
              Darwin.new
              
            when 'linux'
              UI.debug "Analyzing Linux kernel release: #{Gem::Platform.local.kernel_release}"
              case Gem::Platform.local.kernel_release
                
                when /2\.6\.32\-2(1|2)\-generic/
                  UI.debug "Ubuntu 10.04 identified"
                  Ubuntu10.new
                  
                else
                  UI.debug "Debian identified"
                  Debian.new
              end
              
            else
              UI.debug "This Operating System is not supported."
              Base.new
          end
        end
        
      end
    end
  end
end