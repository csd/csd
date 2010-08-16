# -*- encoding: UTF-8 -*-
begin
  require 'rubygems'
rescue LoadError
  puts 'RubyGems could not be found. Please install it first.'
end

begin
  require 'rake'
  require 'rake/testtask'
  require 'rake/rdoctask'
  require 'rdoc'
  require 'jeweler'
rescue LoadError
  puts 'Some gem dependencies are missing. Please install them with:'
  puts '[sudo] gem install rake rdoc shoulda redgreen autotest jeweler activesupport'
end

# This is where we specify the details of this gem. The csd.gemspec file will be generated *automatically* from these specifications.
#
Jeweler::Tasks.new do |gemspec|
  gemspec.name        = "csd"
  gemspec.summary     = "Installation and compilation handler for software used in CSD projects."
  gemspec.description = "CSD stands for Communication Systems Design and is a project of the Telecommunication Systems Laboratory (TSLab) of the Royal Institute of Technology in Stockholm, Sweden. Within CSD many software tools are used to build up various networks and services. This gem is supposed to automate processes to handle the compilation and installation of these software tools. Technology Transfer Alliance (TTA) is the project team, which maintains this code."
  gemspec.email       = "mtoday11@gmail.com"
  gemspec.homepage    = "http://github.com/csd/csd"
  gemspec.authors     = ["Technology Transfer Alliance Team"]
  gemspec.executables = ['ai', 'ttai']
  gemspec.post_install_message = %q{
============================================================

  Thank you for installing the TTA Automated Installer!

  You can run it by typing `ai´ in your command line.

  NOTE: On DEBIAN and UBUNTU the executable `ai´ is *maybe*
        not in your PATH by default. If that is the case,
        you can fix it by running this command:

  echo "export PATH=\$PATH:$(gem env | grep "E D" | sed "s/[^\w]* //")" >> ~/.bashrc;. ~/.bashrc

============================================================
}
end

# Here we define the default task when no task was specified by the user
task :default => :test

# Checks for dependencies and runs all test. Note that it requires you to be online
task :test => :check_dependencies
Rake::TestTask.new :test do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/test_*.rb'
  #t.verbose = true
end

# Generates the source code documentation
Rake::RDocTask.new do |r|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  r.rdoc_dir = 'rdoc'
  r.title = "csd #{version}"
  r.rdoc_files.include('README*')
  r.rdoc_files.include('lib/csd.rb')
  r.rdoc_files.include('lib/csd/**/*.rb')
end

# Analyzes the code test coverage ratio
begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.rcov_opts = ['--sort', 'coverage', '--text-report', '--exclude', "features,kernel,load-diff-lcs\.rb,instance_exec\.rb,lib/spec.rb,lib/spec/runner.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,\.autotest,#{ENV['GEM_HOME']}"]
    t.libs << 'test'
    t.pattern = 'test/**/test_*.rb'
    #t.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install rcov"
  end
end
