# -*- encoding: UTF-8 -*-
# This file gets eval'ed by the global options parser in lib/csd/options_parser

opts.headline 'WORKING DIRECTORY OPTIONS'.green.bold

opts.on("--no-temp", "Use a subdirectory in the current directory as working directory and not /tmp.") do |value|
  self.temp = value
end

opts.on("--work-dir [PATH]", "Defines and/or creates the working directory. This will override the --no-temp option.") do |value|
  self.work_dir = value
end

opts.on("--no-apt-get","Don't run any apt-get commands") do |value|
  self.apt_get = value
end