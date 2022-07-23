# frozen_string_literal: true

require_relative 'lib/sidetree/version'

Gem::Specification.new do |spec|
  spec.name = 'sidetree'
  spec.version = Sidetree::VERSION
  spec.authors = ['azuchi']
  spec.email = ['azuchi@chaintope.com']

  spec.summary = 'Ruby implementation for Sidetree protocol.'
  spec.description = 'Ruby implementation for Sidetree protocol.'
  spec.homepage = 'https://github.com/azuchi/sidetreerb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject do |f|
        f.match(%r{\A(?:test|spec|features)/})
      end
    end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'ecdsa', '~> 1.2.0'
  spec.add_dependency 'json-jwt', '~> 1.13.0'
  spec.add_dependency 'json-canonicalization', '~> 0.3.0'
  spec.add_dependency 'multihashes', '~> 0.2.0'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'prettier', '~> 3.2.0'
  spec.add_development_dependency 'webmock', '~> 3.14.0'
end
