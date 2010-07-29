# -*- encoding: UTF-8 -*-

self.work_dir = nil
opts.on("--work-dir [PATH]", "Defines and/or creates the working directory. This will override the --temp option.") do |value|
  self.work_dir = value
end
