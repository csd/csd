# -*- encoding: UTF-8 -*-
# This file gets eval'ed by the global options parser in lib/csd/rb
# TODO: There must be a nicer solution for this.

opts.on("--path [PATH]",
        "Defines the working directory manually.") do |value|
  self.path = value
end

opts.on("--only libmcrypto,libmnetuli,etc.", Array, "Process only these libraries") do |list|
  self.only = list
end
