require 'rubygems'
require 'rake'
require 'rdoc'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "csd"
    gemspec.summary = "Installation and compilation handler for software used in CSD projects."
    gemspec.description = "CSD stands for Communication Systems Design and is a project of the Telecommunication Systems Laboratory (TSLab) of the Royal Institute of Technology in Stockholm, Sweden. Within CSD many software tools are used to build up various networks and services. This gem is supposed to automate processes to handle the compilation and installation of these software tools. Technology Transfer Alliance (TTA) is the project team, which maintains this code."
    gemspec.email = "mtoday11@gmail.com"
    gemspec.homepage = "http://github.com/csd/csd"
    gemspec.authors = ["Technology Transfer Alliance Team"]
    gemspec.executables = ['tta', 'ai']
    gemspec.post_install_message = %q{
============================================================

 Thank you for installing the TTA Automated Installer!

 You can run it by typing `tta´ in your command line.

 NOTE: On DEBIAN and UBUNTU the executable `tta´ is *maybe*
       not in your PATH by default. If that is the case,
       you can fix it by running this command:
      
 echo "export PATH=\$PATH:$(gem env | grep "E D" | sed "s/[^\w]* //")" >> ~/.bashrc;. ~/.bashrc
       
============================================================
    }
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/functional/**/test*.rb', 'test/unit/**/test_*.rb']
end

Rake::TestTask.new('test:all') do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "csd #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/csd.rb')
  rdoc.rdoc_files.include('lib/csd/**/*.rb')
end
