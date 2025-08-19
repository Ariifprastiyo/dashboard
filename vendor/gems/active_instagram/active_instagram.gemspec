# frozen_string_literal: true

require_relative "lib/active_instagram/version"

Gem::Specification.new do |spec|
  spec.name = "active_instagram"
  spec.version = ActiveInstagram::VERSION
  spec.authors = ["Rafeequl"]
  spec.email = ["rafeequl@seventhsky.id"]

  spec.summary = "API wrapper for Instagram."
  spec.required_ruby_version = ">= 3.0.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob("**/*").reject do |f|
    (File.expand_path(f) == __FILE__) ||
      f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "httparty", "~> 0.21.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
