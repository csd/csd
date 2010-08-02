# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Decklink
      class Base < CSD::Application::Base
       
        def install
          create_working_directory
          define_relative_paths
          download
          extract
          apply
        end
        
        def download
          if Path.tar.file?
            UI.warn "The driver will not be downloaded, because it already exists: #{Path.tar.enquote}"
          else
            UI.info "Downloading DeckLink drivers from Blackmagic Design".green.bold
            Cmd.cd Path.work, :internal => true
            Cmd.run "wget #{Path.decklink_url}", :verbose => false
          end
        end
        
        def extract
          if Path.packages.directory?
            UI.warn "The tar file will not be extracted, because package repositot already exist: #{Path.packages.enquote}"
          else
            UI.info "Extracting DeckLink drivers".green.bold
            Cmd.mkdir Path.packages
            Cmd.cd Path.packages, :internal => true
            Cmd.run "tar -xzf #{Path.tar}"
          end
        end
        
        def apply
          Cmd.cd Path.packages, :internal => true
          archflag = Gem::Platform.local.cpu =~ /64/ ? 'amd64' : 'i386'
          file = Dir[File.join(Path.packages, "Deck*#{archflag}*.deb")]
          UI.debug "#{self.class} identified these applicable packages: #{file.join(', ')}"
          UI.info "Installing Debian packages".green.bold
          Cmd.run "sudo apt-get install libmng1", :announce_pwd => false
          Cmd.run "sudo dpkg -i #{file.first}", :announce_pwd => false
        end
        
        def define_relative_paths
          blacklink_repository  = 'http://www.blackmagic-design.com/downloads/software/'
          decklink_basename     = 'DeckLink_Linux_7.7.3'
          decklink_extension    = '.tar.gz'
          Path.decklink_url     = blacklink_repository + decklink_basename + decklink_extension
          Path.tar              = Pathname.new(File.join(Path.work, "#{decklink_basename + decklink_extension}"))
          Path.packages         = Pathname.new(File.join(Path.work, decklink_basename))
        end
        
        
        
      end
    end
  end
end