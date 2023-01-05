$:.unshift File.expand_path("../lib", __FILE__)
require 'date'
require 'r10k-resolve/version'

Gem::Specification.new do |s|
  s.name              = "r10k-resolve"
  s.version           = R10kResolve::VERSION
  s.date              = Date.today.to_s
  s.summary           = "Simple tool to resolve minimal Puppetfile dependencies."
  s.homepage          = "https://github.com/binford2k/r10k-resolve/"
  s.email             = "binford2k@gmail.com"
  s.authors           = ["Ben Ford"]
  s.license           = "Apache-2.0"
  s.require_path      = "lib"
  s.executables       = %w( r10k-resolve )
  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.add_dependency      'puppetfile-resolver', '~> 0.5.0'

  s.description       = <<-desc
    This will take a Puppetfile.src in which you've described only the Puppet modules
    you actually care about and recursively resolve all of their dependencies into
    a complete Puppetfile ready for use by r10k.
  desc
end
