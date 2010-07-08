require File.join(File.dirname(__FILE__), '..', '..', 'csd_error')

module CSD
  
  class OptionsPathNotFound < CSDError; status_code(200); end

end