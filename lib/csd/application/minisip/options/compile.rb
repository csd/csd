# -*- encoding: UTF-8 -*-
# This file gets eval'ed by the global options parser in lib/csd/options_parser

self.apt_get = true
opts.on("--no-apt-get","Don't run any apt-get commands") do |value|
  self.apt_get = value
end

#self.owner = nil
#opts.on("-o", "--owner [OWNER]","Specify OWNER:GROUP for this operation") do |value|
#  if owner = value
#    chmod = owner.split(':')
#    self.owner = chmod.first
#    self.group = chmod.last
#  end
#end

self.only_fix_giomm = false
opts.on("--only-fix-giomm","Forces the AI to do nothing except trying to bugfix the Ubuntu 10.04 giomm") do |value|
  self.only_fix_giomm = value
end

self.ffmpeg_first = false
opts.on("--ffmpeg-first","Compile FFmpeg before compiling MiniSIP. Default is first MiniSIP.") do |value|
  self.ffmpeg_first = value
end



opts.headline 'MINISIP LIBRARY OPTIONS'.green.bold

self.bootstrap = true
opts.on("--no-bootstrap","Don't run the bootstrap command on any MiniSIP library") do |value|
  self.bootstrap = value
end

self.configure = true
opts.on("--no-configure","Don't run the configure command on any MiniSIP library") do |value|
  self.configure = value
end

self.make = true
opts.on("--no-make","Don't run the make command on any MiniSIP library") do |value|
  self.make = value
end

self.make_install = true
opts.on("--no-make-install","Don't run the make install command on any MiniSIP library") do |value|
  self.make_install = value
end

opts.on("--only libmutil,libmsip,etc.", Array, "Process only these libraries") do |list|
  self.only = list
end
