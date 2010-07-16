# -*- encoding: UTF-8 -*-
require 'csd/container'

module CSD
  
  # This global variable holds the version number of this gem by trying to read the VERSION file.
  # If the VERSION file cannot be read, it will be defined to 0.0.0 as a fallback.
  # Ideally it would be hardcoded in this file, because it cannot be guaranteed that the VERSION
  # file exists (see http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices). But we
  # use it anyway, because Jeweler (a gem to create gems more easily) needs it and the risk is not that big.
  #
  Version = VERSION = begin
    File.read(File.join(Path.gem, 'VERSION'))
  rescue Errno::ENOENT => e
    UI.debug "The VERSION file could not be found. Setting `Version´ to 0.0.0"
    '0.0.0'
  end
  
end