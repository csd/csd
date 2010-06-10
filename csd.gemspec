# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{csd}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Technology Transfer Alliance Team"]
  s.date = %q{2010-06-10}
  s.default_executable = %q{csd}
  s.description = %q{CSD stands for Communication Systems Design and is a project of the Telecommunication Systems Laboratory (TSLab) of the Royal Institute of Technology in Stockholm, Sweden. Within CSD many software tools are used to build up various networks and services. This gem is supposed to automate processes to handle the compilation and installation of these software tools. Technology Transfer Alliance (TTA) is the project team, which maintains this code.}
  s.email = %q{mtoday11@gmail.com}
  s.executables = ["csd"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/csd",
     "csd.gemspec",
     "lib/apps/minisip.rb",
     "lib/csd.rb",
     "lib/csd/installer.rb",
     "lib/csd/loader.rb",
     "lib/csd/shared.rb",
     "test/helper.rb",
     "test/test_csd.rb"
  ]
  s.homepage = %q{http://github.com/csd/csd}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Installation and compilation handler for software used in CSD projects.}
  s.test_files = [
    "test/helper.rb",
     "test/test_csd.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 0"])
    else
      s.add_dependency(%q<term-ansicolor>, [">= 0"])
    end
  else
    s.add_dependency(%q<term-ansicolor>, [">= 0"])
  end
end

