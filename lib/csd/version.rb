# encoding: utf-8
require File.join(File.dirname(__FILE__), 'path')

module CSD
  
  # This global variable holds the version number of this gem by reading the VERSION file.
  #
  Version = VERSION = File.read(File.join(Path.gem, 'VERSION')) unless defined?(Version)
  
end