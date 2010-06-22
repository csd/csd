# This file gets eval'ed by the global options parser in lib/csd/options.rb
# TODO: There must be a nicer solution for this.

options.temp         = false
options.bootstrap    = true
options.configure    = true
options.make         = true
options.make_install = true
options.owner        = nil
options.apt_get      = true

opts.on("-t", "--temp",
        "Use a subdirectory in the system's temporary directory",
        "to download files and not the current directory") do |value|
  options.temp = value
end

opts.on("-o", "--owner [OWNER]","Specify OWNER:GROUP for this operation") do |value|
  if options.owner = value
    chmod = options.owner.split(':')
    options.owner = chmod.first
    options.group = chmod.last
  end
end

opts.on("-p", "--path [PATH]",
        "Defines the working directory manually.",
        "(This will override the --temp option)") do |value|
  options.path = value
end

opts.on("-na", "--no-apt-get","Don't run any apt-get commands") do |value|
  options.apt_get = value
end

opts.on("-nb", "--no-bootstrap","Don't run any bootstrap commands") do |value|
  options.bootstrap = value
end

opts.on("-nc", "--no-configure","Don't run any configure commands") do |value|
  options.configure = value
end

opts.on("-nm", "--no-make","Don't run any make commands") do |value|
  options.make = value
end

opts.on("-nmi", "--no-make-install","Don't run any make install commands") do |value|
  options.make_install = value
end

opts.on("--only libmcrypto,libmnetuli,etc.", Array, "Include only these libraries") do |list|
  options.only = list
end