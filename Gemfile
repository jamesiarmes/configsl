# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development do
  gem 'rake', '~> 13.2'
  gem 'rubocop', '~> 1.65'
  gem 'rubocop-factory_bot', '~> 2.26'
  gem 'rubocop-rake', '~> 0.6'
  gem 'rubocop-rspec', '~> 3.0'
end

group :test do
  # activesupport 7.2 introduces a breaking change that causes the specs to
  # fail.
  gem 'activesupport', '~> 8.1.3'

  gem 'coveralls_reborn', '~> 0.28'
  gem 'factory_bot', '~> 6.4'
  gem 'rspec', '~> 3.13'
  gem 'rspec-github', '~> 3.0'
  gem 'simplecov', '~> 0.22'
end
