# Defining application wide constants
ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))  # Absolute root directory of this gem
Version   = File.read(File.join(ROOT_PATH, 'VERSION'))                 # Version number of this gem

# Loading libraries
Dir.glob(File.join(File.dirname(__FILE__), 'extensions', '**', '*.rb')) { |file| require file }
require File.join(File.dirname(__FILE__), 'csd', 'init')
