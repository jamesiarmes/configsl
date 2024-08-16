# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'configsl'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = 'ConfigSL is a simple configuration DSL.'
  s.description = 'A simple, modular, extensible DSL for configuration.'
  s.authors     = ['James I. Armes']
  s.email       = 'jamesiarmes@gmail.com'
  s.files       = Dir['lib/**/*'] + Dir['Gemfile']
  s.homepage    = 'https://github.com/jamesiarmes/configsl'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/jamesiarmes/configsl/issues',
    'homepage_uri' => s.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/jamesiarmes/configsl'
  }

  s.required_ruby_version = '>= 3.2'

  s.add_dependency 'facets', '~> 3.1'
end
