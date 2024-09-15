# frozen_string_literal: true

require_relative 'lib/configsl/version'

Gem::Specification.new do |s|
  s.name        = 'configsl'
  s.version     = ConfigSL::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'A simple DSL for declarative configuration in ruby.'
  s.description = 'A simple, modular, extensible DSL for configuration.'
  s.authors     = ['James I. Armes']
  s.email       = 'jamesiarmes@gmail.com'
  s.files       = Dir['lib/**/*'] + Dir['Gemfile']
  s.extra_rdoc_files = %w[README.md CHANGELOG.md]
  s.homepage    = 'https://github.com/jamesiarmes/configsl'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/jamesiarmes/configsl/issues',
    'changelog_uri' => 'https://github.com/jamesiarmes/configsl/blob/main/CHANGELOG.md',
    'homepage_uri' => s.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/jamesiarmes/configsl'
  }

  s.required_ruby_version = '>= 3.2'

  s.add_dependency 'facets', '~> 3.1'
end
