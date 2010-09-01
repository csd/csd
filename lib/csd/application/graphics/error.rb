# -*- encoding: UTF-8 -*-
require 'csd/error'

module CSD
  module Error
    module Graphics
      
      # See 'csd/error' to find out which status code range has been assigned to Graphics
      
      class CardNotSupported < CSDError; status_code(300); end
      class Amd64NotSupported < CSDError; status_code(301); end
      class XServerStillRunning < CSDError; status_code(302); end
      
    end
  end
end