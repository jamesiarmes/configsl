# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][changelog], and this project adheres
to [Semantic Versioning][versioning].

## [1.1.1]

### Fixed

- Reported gem version

## [1.1.0]

### Added

- Support collections of configuration objects with the new `Collection` module
- Add `ToHash` module for converting configuration objects to hashes using
  `to_h`
- Create setter methods for options
- Added `Merge` module to merge parameters from multiple sources

### Fixed

- Renamed `@params` to `@configsl_params` to avoid collisions
- Add `configsl_` prefix to more methods to avoid conflicts

### Deprecated

- `FileSupport.find_file` is deprecated; use `configsl_find_file` instead
- `FileSupport.find_file_format` is deprecated; use `configsl_find_file_format`
  instead

## [1.0.2]

### Added

- Moved `ConfigSL::VERSION` to `configsl/version` for easier reference.
- Exposed the shared example for file formats. Include it in your specs with:

   ```ruby
   require 'configsl/file_format/shared_spec'

   RSpec.describe MyFileFormat do
     it_behaves_like 'a file format', 'spec-config.json', %i[json], {
       format: 'JSON',
       name: 'config.json',
       nested: { title: 'JSON file for testing' }
     }
   end
   ```

## [1.0.1]

### Fixed

- Subclasses of `ConfigSL::Config` initialized with sting keys no longer raise
  an error.

## 1.0.0

Initial release.

### Added

- Simple DSL for defining configuration
- JSON and YAML file reading support
- Environment variable reading support
- Formatting and validation of values

[changelog]: https://keepachangelog.com/en/1.1.0/
[versioning]: https://semver.org/spec/v2.0.0.html
