Dir.glob(File.join(File.dirname(__FILE__), 'extensions', '*.rb')) { |file| require file }
require File.join(File.dirname(__FILE__), 'csd', 'init')
