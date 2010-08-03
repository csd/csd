# -*- encoding: UTF-8 -*-

opts.headline 'WORKING DIRECTORY OPTIONS'.green.bold

self.temp = true
opts.on("--no-temp", "Use the current directory as working directory and not a system's temporary directory.") do |value|
  self.temp = !value
end

self.work_dir = nil
opts.on("--work-dir [PATH]", "Defines and/or creates the working directory. This will override the --pwd option.") do |value|
  self.work_dir = value
end
