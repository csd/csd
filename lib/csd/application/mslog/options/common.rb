# -*- encoding: UTF-8 -*-

opts.headline 'WORKING DIRECTORY OPTIONS'.green.bold

opts.on("--work-dir [PATH]", "Defines and/or creates the working directory. This will override the --no-temp option.") do |value|
  self.work_dir = value
end
