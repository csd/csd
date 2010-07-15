# encoding: utf-8
require 'csd/container'

module CSD
  
  # This global variable holds the version number of this gem by trying to read the VERSION file.
  # If the VERSION file cannot be read, it will be defined to 0.0.0 as a fallback.
  #
  Version = VERSION = begin
    File.read(File.join(Path.gem, 'VERSION'))
  rescue Errno::ENOENT => e
    UI.debug "The VERSION file could not be found. Setting `Version´ to 0.0.0"
    '0.0.0'
  end
  
end