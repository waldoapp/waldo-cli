# Changelog

All notable changes to this project will be documented in this file. The format
is based on [Keep a Changelog].

This project adheres to [Semantic Versioning].

## [Unreleased]

## [1.6.0] - 2020-06-01

### Added

- Added support for optionally finding and uploading symbols associated with
  iOS simulator builds

### Changed

- Updated `CI_INTEGRATION.md` document.

## [1.5.0] - 2020-04-14

### Added

- Added support for optionally uploading symbols associated with the build (IPA
  only).

### Removed

- Removed current git commit SHA uploading.

## [1.4.2] - 2020-02-11

### Added

- Added support for uploading the current git commit SHA associated with a
  build if the script is executed from a git repository.

## [1.4.1] - 2020-02-06

### Fixed

- Fixed issues running on Linux.

## [1.4.0] - 2019-12-27

### Changed

- Enhanced error reporting.

### Fixed

- Fixed some issues with Base64 encoding and JSON string quoting.

## [1.3.0] - 2019-08-02

### Added

- Added support for uploading the git commit history (SHAs and branch names
  only) associated with a build if the script is executed from a git repository.

## [1.2.1] - 2019-05-21

### Changed

- Enhanced error handling.

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

[Unreleased]:   https://github.com/waldoapp/waldo-cli/compare/1.6.0...HEAD
[1.6.0]:        https://github.com/waldoapp/waldo-cli/compare/1.5.0...1.6.0
[1.5.0]:        https://github.com/waldoapp/waldo-cli/compare/1.4.2...1.5.0
[1.4.2]:        https://github.com/waldoapp/waldo-cli/compare/1.4.1...1.4.2
[1.4.1]:        https://github.com/waldoapp/waldo-cli/compare/1.4.0...1.4.1
[1.4.0]:        https://github.com/waldoapp/waldo-cli/compare/1.3.0...1.4.0
[1.3.0]:        https://github.com/waldoapp/waldo-cli/compare/1.2.1...1.3.0
[1.2.1]:        https://github.com/waldoapp/waldo-cli/compare/1.2.0...1.2.1
[1.2.0]:        https://github.com/waldoapp/waldo-cli/compare/1.1.0...1.2.0
[1.1.0]:        https://github.com/waldoapp/waldo-cli/compare/1.0.0...1.1.0
[1.0.0]:        https://github.com/waldoapp/waldo-cli/compare/c7c5b82...1.0.0

[Keep a Changelog]:     https://keepachangelog.com
[Semantic Versioning]:  https://semver.org
