# Changelog

All notable changes to this project will be documented in this file. The format
is based on [Keep a Changelog].

This project adheres to [Semantic Versioning].

## [Unreleased]

## [1.6.6] - 2021-06-10

### Added

- Added detection and reporting of active GitHub Actions CI.

### Changed

- Updated `CI_INTEGRATION.md` document to cover GitHub Actions.

### Fixed

- Fixed erroneous reporting of the git SHA from a GitHub Actions workflow when
  merging via pull request.

## [1.6.5] - 2021-04-01

### Fixed

- Fixed erroneous `sim_build_upload.sh` Bash script.

### Changed

- Improved `SIM_APPCENTER.md` document.

## [1.6.4] - 2021-03-15

### Added

- Added `SIM_APPCENTER.md` document describing App Center iOS simulator build
  workaround in great detail.

### Changed

- Replaced `sim_build_upload.sh` with improved
  `sim_appcenter_build_and_upload.sh` Bash script to help App Center users
  build for iOS simulator.

## [1.6.3] - 2021-02-25

### Added

- Added `sim_build_upload.sh` Bash script to release to help App Center users
  build for iOS simulator.

## [1.6.2] - 2020-10-09

### Changed

- Further enhanced detection and reporting of active CI.
- Further updated `CI_INTEGRATION.md` document again.

## [1.6.1] - 2020-06-03

### Changed

- Enhanced detection and reporting of active CI.
- Further updated `CI_INTEGRATION.md` document.

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

[Unreleased]:   https://github.com/waldoapp/waldo-cli/compare/1.6.6...HEAD
[1.6.6]:        https://github.com/waldoapp/waldo-cli/compare/1.6.5...1.6.6
[1.6.5]:        https://github.com/waldoapp/waldo-cli/compare/1.6.4...1.6.5
[1.6.4]:        https://github.com/waldoapp/waldo-cli/compare/1.6.3...1.6.4
[1.6.3]:        https://github.com/waldoapp/waldo-cli/compare/1.6.2...1.6.3
[1.6.2]:        https://github.com/waldoapp/waldo-cli/compare/1.6.1...1.6.2
[1.6.1]:        https://github.com/waldoapp/waldo-cli/compare/1.6.0...1.6.1
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
