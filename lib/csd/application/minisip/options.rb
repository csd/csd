# This file gets eval'ed by the global options parser in lib/csd/rb
# TODO: There must be a nicer solution for this.

temp = false
opts.on("-t", "--temp",
        "Use a subdirectory in the system's temporary directory",
        "to download files and not the current directory") do |value|
  temp = value
end

owner = nil
opts.on("-o", "--owner [OWNER]","Specify OWNER:GROUP for this operation") do |value|
  if owner = value
    chmod = owner.split(':')
    owner = chmod.first
    group = chmod.last
  end
end

opts.on("--path [PATH]",
        "Defines the working directory manually.",
        "(This will override the --temp option)") do |value|
  path = value
end

apt_get = true
opts.on("--no-apt-get","Don't run any apt-get commands") do |value|
  apt_get = value
end

bootstrap = true
opts.on("--no-bootstrap","Don't run any bootstrap commands") do |value|
  bootstrap = value
end

opts.on("--no-configure","Don't run any configure commands") do |value|
  configure = value
end

make = true
opts.on("--no-make","Don't run any make commands") do |value|
  make = value
end

make_install = true
opts.on("--no-make-install","Don't run any make install commands") do |value|
  make_install = value
end

opts.on("--only libmcrypto,libmnetuli,etc.", Array, "Include only these libraries") do |list|
  only = list
end