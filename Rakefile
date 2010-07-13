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
    #gemspec.add_dependency "term-ansicolor", ">= 0"
    #gemspec.add_dependency "activesupport", "3.0.0.beta3"  # needs to be active_support in the next release of it, I guess
    gemspec.executables = ["ai"]
    gemspec.post_install_message = %q{
    ==================================================================================

    Thank you for installing the Communication Systems and Design Automated Installer!
    You can run it by just typing `ai´ in your command line.
    
    . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    
    Note: On Debian and Ubuntu the executable `ai´ is not in your PATH by default.
          You can fix this problem by creating a symlink with these two commands:
          
          GEMBIN=$(gem env | grep "E D" | sed "s/[^\w]* //")
          sudo ln -s "${GEMBIN}/ai" /usr/local/bin/ai
          
    ==================================================================================
    }
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
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
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
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
  rdoc.rdoc_files.include('lib/**/*.rb')
end
