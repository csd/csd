# -*- encoding: UTF-8 -*-
# This file gets eval'ed by the global options parser in lib/csd/options_parser

self.this_user = false
opts.on("--this-user","Compile MiniSIP only for the current user (enforces the --no-temp option)") do |value|
  self.this_user = value
end

self.apt_get = true
opts.on("--no-apt-get","Don't run any apt-get commands") do |value|
  self.apt_get = value
end

self.ffmpeg_first = false
opts.on("--ffmpeg-first","Compile FFmpeg before compiling MiniSIP (default is first MiniSIP)") do |value|
  self.ffmpeg_first = value
end

self.branch = nil
opts.on('--branch BRANCH', 'Choose another branch than `master´ when downloading the source code') do |lib|
  self.branch = value
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
