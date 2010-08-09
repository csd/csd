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
          UI.debug "#{self}.instance checks whether MiniSIP is supported for the OS #{Gem::Platform.local.os.enquote}"
          @instance ||= case Gem::Platform.local.os
            
            when 'darwin'
              # Mac OS X
              UI.debug "#{self}.instance supports Mac OS X"
              Darwin.new
            
            when 'linux'
              # Linux
              case Gem::Platform.local.cpu

                when 'x86'
                  # 32 bit
                  UI.debug "#{self}.instance supports Linux (32 bit)"
                  UI.debug "#{self}.instance analyzes the Linux kernel release #{Gem::Platform.local.kernel_release.to_s.enquote}"
                  case Gem::Platform.local.kernel_release

                    when '2.6.32-21-generic', '2.6.32-22-generic'
                      # Ubuntu 10.04
                      UI.debug "#{self}.instance supports Ubuntu 10.04"
                      Ubuntu10.new

                    else
                      # Any other Linux (currently only Debian is supported)
                      UI.debug "#{self}.instance supports Debian"
                      Debian.new
                  end
                
                else
                  # 64 bit
                  UI.debug "#{self}.instance found the architecture to be other than 'x86', but 64 bit is not supported"
                  raise Error::Minisip::Amd64NotSupported, "Sorry, 64-bit systems are currently not supported by MiniSIP."
              end
              
            else
              # Microsoft Windows, Java, Solaris, etc...
              UI.debug "#{self}.instance does not support #{Gem::Platform.local.os.enquote}"
              # NOTE: The AI should actually abort here as long as there is no MiniSIP for these platforms at all...
              Base.new
          end
        end
        
      end
    end
  end
end