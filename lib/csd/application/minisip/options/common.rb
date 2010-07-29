# -*- encoding: UTF-8 -*-

opts.headline 'WORKING DIRECTORY OPTIONS'.green.bold

self.temp = false
opts.on("-t", "--temp", "Use a system's temporary directory as working directory.") do |value|
  self.temp = value
end

self.work_dir = nil
opts.on("--work-dir [PATH]", "Defines and/or creates the working directory. This will override the --temp option.") do |value|
  self.work_dir = value
end
