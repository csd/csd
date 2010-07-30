# -*- encoding: UTF-8 -*-
require 'csd/error'

module CSD
  module Error
  
    module Options
      class PathNotFound < CSDError; status_code(200); end
    end
    
  end
end