# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][changelog], and this project adheres
to [Semantic Versioning][versioning].

## [Unreleased]

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
