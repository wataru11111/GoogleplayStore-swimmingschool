# -*- encoding: utf-8 -*-
# stub: planetscale_rails 0.2.9 ruby lib

Gem::Specification.new do |s|
  s.name = "planetscale_rails".freeze
  s.version = "0.2.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "homepage_uri" => "https://github.com/planetscale/planetscale_rails", "source_code_uri" => "https://github.com/planetscale/planetscale_rails" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Coutermarsh".freeze, "Iheanyi Ekechukwu".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-02-26"
  s.description = "A collection of rake tasks to make managing schema migrations with PlanetScale easy".freeze
  s.email = ["coutermarsh.mike@gmail.com".freeze, "iekechukwu@gmail.com".freeze]
  s.homepage = "https://github.com/planetscale/planetscale_rails".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.3.27".freeze
  s.summary = "Make Rails migrations easy with PlanetScale".freeze

  s.installed_by_version = "3.3.27" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<colorize>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<rails>.freeze, [">= 6.0", "< 9"])
  else
    s.add_dependency(%q<colorize>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rails>.freeze, [">= 6.0", "< 9"])
  end
end
