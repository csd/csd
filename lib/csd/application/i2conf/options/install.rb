# -*- encoding: UTF-8 -*-
# This file gets eval'ed by the global options parser in lib/csd/options_parser

opts.on("--no-apt-get","Don't run any apt-get commands") do |value|
  self.apt_get = value
end

opts.on("--no-minisip","Don't install the MiniSIP libraries (needed by i2conf)") do |value|
  self.minisip = value
end