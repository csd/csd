# -*- encoding: UTF-8 -*-
# This file gets eval'ed by the global options parser in lib/csd/options_parser

#opts.on("--this-user","Compile MiniSIP only for the current user (enforces the --no-temp option)") do |value|
#  self.this_user = value
#end

opts.on("--no-apt-get","Don't run any apt-get commands") do |value|
  self.apt_get = value
end

opts.on("--force-ffmpeg","Do not remove FFmpeg before compiling MiniSIP and compile FFmpeg before MiniSIP") do |value|
  self.ffmpeg_first = value
end

opts.on("--github-tar","Instead of fetching git repositories from Github, use tarball downloads") do |value|
  self.github_tar = value
end

opts.on("--vendor","Use the latest, untested version from the vendor's repository (SVN) instead of Github") do |value|
  self.vendor = value
end

opts.on('--branch BRANCH', 'Choose another branch than `master´ when downloading the source code') do |value|
  self.branch = value
end

opts.headline 'MINISIP LIBRARY OPTIONS'.green.bold

opts.on("--no-bootstrap","Don't run the bootstrap command on any MiniSIP library") do |value|
  self.bootstrap = value
end

opts.on("--no-configure","Don't run the configure command on any MiniSIP library") do |value|
  self.configure = value
end

opts.on("--no-make","Don't run the make command on any MiniSIP library") do |value|
  self.make = value
end

opts.on("--no-make-install","Don't run the make install command on any MiniSIP library") do |value|
  self.make_install = value
end

opts.on("--threads [OCTAL]", OptionParser::OctalInteger, "Simultaneous compiling with this many threads (e.g. 10)") do |value|
  self.threads = value
end

opts.on("--only libmutil,libmsip,etc.", Array, "Process only these libraries") do |list|
  self.only = list
end

opts.on("--enable-debug","Enable full MiniSIP-internal debugging") do |value|
  self.enable_debug = value
end

opts.on("--enable-debug-on libmsip,..", Array, "Enable MiniSIP-internal debugging only for these libraries") do |list|
  self.enable_debug_on = list
end