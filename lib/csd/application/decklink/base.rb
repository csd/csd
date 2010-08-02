# -*- encoding: UTF-8 -*-
require 'csd/application/default/base'

module CSD
  module Application
    module Decklink
      class Base < CSD::Application::Base
       
        BL_URL = 'http://www.blackmagic-design.com/downloads/software/'
        DL_FILE = 'DeckLink_Linux_7.7.3'
        DL_URL = BL_URL + DL_FILE + '.tar'
       
        def install
          create_working_directory
          download
        end
        
        def download
          if Path.tar.file?
            UI.warn "The driver will not be downloaded, because it already exists: #{Path.tar.enquote}"
          else
            Cmd.cd Path.work
            Cmd.run "wget #{DL_URL}"
          end
        end
        
        def define_relative_paths
          Path.tar           = Pathname.new(File.join(Path.work, "#{DL_FILE}.tar"))
        end
        
       
        
      end  
    end
  end
end   