# This file gets eval'ed by the global options parser in lib/csd/rb
# TODO: There must be a nicer solution for this.

self.temp = false
opts.on("-t", "--temp",
        "Use a subdirectory in the system's temporary directory",
        "to download files and not the current directory") do |value|
  self.temp = value
end

self.owner = nil
opts.on("-o", "--owner [OWNER]","Specify OWNER:GROUP for this operation") do |value|
  if owner = value
    chmod = owner.split(':')
    self.owner = chmod.first
    self.group = chmod.last
  end
end

self.path = nil
opts.on("--path [PATH]",
        "Defines the working directory manually.",
        "(This will override the --temp option)") do |value|
  self.path = value
end

self.apt_get = true
opts.on("--no-apt-get","Don't run any apt-get commands") do |value|
  self.apt_get = value
end

self.bootstrap = true
opts.on("--no-bootstrap","Don't run any bootstrap commands") do |value|
  self.bootstrap = value
end

opts.on("--no-configure","Don't run any configure commands") do |value|
  self.configure = value
end

self.make = true
opts.on("--no-make","Don't run any make commands") do |value|
  self.make = value
end

self.make_install = true
opts.on("--no-make-install","Don't run any make install commands") do |value|
  self.make_install = value
end

opts.on("--only libmcrypto,libmnetuli,etc.", Array, "Include only these libraries") do |list|
  self.only = list
end