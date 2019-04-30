# Changelog

All notable changes to this project will be documented in this file. The format
is based on [Keep a Changelog].

This project adheres to [Semantic Versioning].

## [Unreleased]

## [1.2.0] - 2019-04-30

### Added

- Added support for iOS simulator builds (`.app`).

## [1.1.0] - 2018-12-27

### Added

- Added `--variant_name` option.
- Added support for `WALDO_VARIANT_NAME` environment variable.
- Added `CI_INTEGRATION.md` document.

### Changed

- Renamed `--key` option to `--upload_token`.
- Renamed `WALDO_API_KEY` environment variable to `WALDO_UPLOAD_TOKEN`.

### Removed

- Removed `--application` option.
- Removed support for `WALDO_APPLICATION_ID` environment variable.

## [1.0.0] - 2018-12-05

Initial public release.

[Unreleased]:   https://github.com/waldoapp/waldo-cli/compare/1.2.0...HEAD
[1.2.0]:        https://github.com/waldoapp/waldo-cli/compare/1.1.0...1.2.0
[1.1.0]:        https://github.com/waldoapp/waldo-cli/compare/1.0.0...1.1.0
[1.0.0]:        https://github.com/waldoapp/waldo-cli/compare/c7c5b82...1.0.0

[Keep a Changelog]:     https://keepachangelog.com
[Semantic Versioning]:  https://semver.org
