# ConfigSL [![Gem Version](https://badge.fury.io/rb/configsl.svg)](https://badge.fury.io/rb/configsl) [![Coverage Status][badge-coverage]][coverage] [![Code Checks](https://github.com/jamesiarmes/configsl/actions/workflows/checks.yaml/badge.svg?branch=main)](https://github.com/jamesiarmes/configsl/actions/workflows/checks.yaml)

ConfigSL is a simple Domain-Specific Language (DSL) module for configuration.
It is designed to provide a declarative way to define configuration, with as few
dependencies and additional cruft as possible. It is both modular and
extensible, so you can use as little or as much as you need.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'configsl'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install configsl
```

## Usage

You can start defining your configurations using two methods:

1. Extend the included `ConfigSL::Config` base class
2. Include the `ConfigSL` modules you want to use in you class

### Using the included base class

The `ConfigSL::Config` base class includes common functionality for working with
configurations. Currently, the class provides the following features:

- **DSL**: The primary DSL for defining configuration options
- **Format**: A simple way to enforce option value formatting
- **FromEnvironment**: Load configuration from environment variables
- **FromFile**: Load configuration from a file
- **Validation**: Built-in validation for configuration options

```ruby
require 'configsl'

class AppConfig < ConfigSL::Config
    register_file_format :json
    register_file_format :yaml

    option :name, type: String, default: 'My App'
    option :environment, type: Symbol, enum: %i[dev test prod], default: :dev,
                         env_variable: 'RACK_ENV'
    option :database, type: DatabaseConfig, required: true
end
```

### Including modules

If you'd like to pick and choose the features you want to use, you can include
modules individually. _Most_ modules can be included in any order, but the `DSL`
module _**must**_ be included before any others.

Additionally, you will need to implement `initialize` -- or some other method --
that sets the configuration values by calling `set_value` for each option.

```ruby
require 'configsl'

class ApplicationConfig
    include ConfigSL::DSL
    include ConfigSL::Format
    include ConfigSL::FromEnvironment

    option :name, type: String, default: 'My App'
    option :environment, type: Symbol, env_variable: 'RACK_ENV'
    option :database, type: DatabaseConfig

    def initialize(params = {})
      params.each do |name, value|
        set_value(name, value)
      end
    end
end
```

### A note about inheritance

When working with multiple configuration classes, you'll likely want to use a
base class. This could be the `ConfigSL::Config` class, or a custom class that
includes the modules you need.

While the modules you include are inherited by subclasses, any options you
define via DSL are not. This is because these values are stored using _class
instance variables_. As a result, if you have options that are shared between
classes, they will need to be implemented in both.

It's important to note that this is not limited to your defined configuration
options, but also methods such as `register_file_format` and
`config_file_path`.

[badge-coverage]: https://coveralls.io/repos/github/jamesiarmes/configsl/badge.svg
[coverage]: https://coveralls.io/github/jamesiarmes/configsl
