$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pokotarou/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pokotarou"
  s.version     = Pokotarou::VERSION
  s.authors     = ["Kashiwara"]
  s.email       = ["tamatebako0205@gmail.com"]
  s.summary     = "This gem is seeder which is very usefull"
  s.description = "Pokotarou is convenient seeder of 'Ruby on Rails'"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0"
  s.add_dependency 'activerecord-import', '>= 1.00'
end
