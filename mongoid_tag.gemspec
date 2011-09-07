# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongoid_tag/version"

Gem::Specification.new do |s|
  s.name        = "mongoid_tag"
  s.version     = MongoidTag::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christian Hager"]
  s.email       = ["christian@rondeventure.com"]
  s.homepage    = %q{http://github.com/christianhager/mongoid_tag}
  s.summary = %q{Mongoid tagging with scope and meta}
  s.description = %q{Mongoid tagging gem that holds meta about tags in a scoped context.}

  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  s.rubygems_version = %q{1.6.2}

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]

  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "init.rb",
    "lib/mongoid_tag/tag.rb",
    "lib/mongoid_tag/meta.rb",
    "lib/mongoid_tag/meta_tag.rb",
    "lib/mongoid_tag.rb",
    "mongoid_tag.gemspec",
    "spec/mongoid_tag_spec.rb",
    "spec/spec_helper.rb"
  ]

  s.test_files = [
    "spec/mongoid_tag_spec.rb",
    "spec/spec_helper.rb"
  ]

  s.add_development_dependency(%q<database_cleaner>, [">= 0"])
  s.add_development_dependency(%q<rspec>, ["~> 2.3.0"])
  s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
  s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
  s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
  s.add_development_dependency(%q<rcov>, [">= 0"])
  s.add_development_dependency(%q<reek>, ["~> 1.2.8"])
  s.add_development_dependency(%q<roodi>, ["~> 2.1.0"])

  s.add_dependency(%q<mongoid>)
  s.add_dependency(%q<bson>)
  s.add_dependency(%q<bson_ext>)
  s.add_dependency(%q<bundler>)

end
