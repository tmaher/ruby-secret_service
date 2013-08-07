require 'find'

Gem::Specification.new do |s|
  s.name = 'ruby-secret-service'
  s.version = File.read("VERSION").chomp
  s.summary = 'Ruby bindings for GNOME Keyring & KWallet'
  s.description = "Native bindings use the D-BUS Secret Service API, docs at http://standards.freedesktop.org/secret-service/"
  s.authors = ["Tom Maher"]
  s.email = "tmaher@pw0n.me"
  s.license = "Apache 2.0"
  s.files = `git ls-files`.split("\n")
  s.homepage = "https://github.com/tmaher/ruby-secret-service"
  s.add_development_dependency "woof_util"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.add_dependency "ruby-dbus"
end
