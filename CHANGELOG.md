# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [Unreleased]

- Improve interface output appearance
- Improve handling of command line options
- Add capability to tidy up and exit gracefully upon receiving CTRL-C interrupts

## [0.4.0] - 2025-06-14

### Changed

- Less cryptic outcome messages
- More robust implementation of progress bar
- Use /tmp to store programme temporary data instead of current directory

### Fixed

- Fix logic that gets current progress (so that negative values are ignored)
- Fix typos in documentation


## [0.3.1] - 2025-06-11

### Fixed

- Fix typo in PKGBUILD version number

## [0.3.0] - 2025-06-11

### Added

- Report percentage progress when compressing video
- Progress bar

### Changed

- Improve appearance of information provided to user

### Fixed

- Fix typos in README
- Fix number of iterations when -t option selected

## [0.2.0] - 2025-06-07

### Added

- Initial version
- Change log
