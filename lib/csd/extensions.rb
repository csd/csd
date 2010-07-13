# encoding: utf-8
Dir.glob(File.join(File.dirname(__FILE__), 'extensions', '**', '*.rb')) { |file| require file }
