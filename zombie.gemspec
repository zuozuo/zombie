$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "zombie/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "zombie"
  s.version     = Zombie::VERSION
  s.authors     = ["zuozuo"]
  s.email       = ["zuoyh@edaixi.com"]
  s.homepage    = "https://github.com/rongchang/zombie"
	s.summary     = "Api server service and client"
	s.description = "Api server service and client, used by edaixi api_server"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0"
  s.add_dependency "rest-client"
  s.add_dependency "grape"
  s.add_dependency "redis"
  s.add_dependency "redis-rails"
  s.add_dependency "redis-objects"
	s.add_dependency 'hashie-forbidden_attributes'

  s.add_development_dependency "rake"
  s.add_development_dependency 'byebug'
  s.add_development_dependency "spring"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "bundler"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "minitest-reporters"
end
