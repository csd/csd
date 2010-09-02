# -*- encoding: UTF-8 -*-
# This file gets eval'ed by the global options parser in lib/csd/rb


opts.on("--force-geforce","Skip graphical card checking and force to install GeForce drivers") do |value|
  self.force_geforce = value
end

opts.on("--force-radeon","Skip graphical card checking and force to install Radeon drivers") do |value|
  self.force_radeon = value
end