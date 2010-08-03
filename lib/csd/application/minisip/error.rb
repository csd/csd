# -*- encoding: UTF-8 -*-
require 'csd/error'

module CSD
  module Error
    module Minisip
      
      # See 'csd/error' to find out which status code range has been assigned to MiniSIP
      
      class BuildDirNotFound < CSDError; status_code(200); end
      
      module Core
        class FFmpegInstalled < CSDError; status_code(210); end
      end
      
    end
  end
end