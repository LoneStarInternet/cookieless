# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cookieless"
  s.version = "0.3.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jinzhu", "chrisboy333", "mepatterson"]
  s.date = "2012-01-06"
  s.description = "Cookieless is a rack middleware to make your application works with cookie-less devices/browsers without change your application; Forked from Jinzhu's github branch. This branch is now specific to our internal CB project. DO NOT USE IT FOR ANYTHING ELSE."
  s.email = "wosmvp@gmail.com"
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc"]
  s.files = ["LICENSE.txt", "README.rdoc"]
  s.homepage = "http://github.com/LoneStarInternet/cookieless"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Cookieless is a rack middleware to make your application works with cookie-less devices/browsers without change your application; Forked from Jinzhu's github branch. This branch is now specific to our internal CB project. DO NOT USE IT FOR ANYTHING ELSE."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end
