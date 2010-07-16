# -*- encoding: UTF-8 -*-
Dir[File.join(File.dirname(__FILE__), 'extensions', 'core', '*.rb')].sort.each { |path| require "csd/extensions/core/#{File.basename(path, '.rb')}" }
Dir[File.join(File.dirname(__FILE__), 'extensions', 'gem', '*.rb')].sort.each { |path| require "csd/extensions/gem/#{File.basename(path, '.rb')}" }
