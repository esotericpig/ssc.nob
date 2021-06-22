# Changelog | SSC.Nob

All notable changes to this project will be documented in this file.

Format is based on [Keep a Changelog v1.0.0](https://keepachangelog.com/en/1.0.0),
and this project adheres to [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html).

## [[Unreleased]](https://github.com/esotericpig/ssc.nob/compare/v0.1.1...HEAD)
-


## [v0.1.1] - 2021-06-22

### Added
- Added use of Warbler to create a runnable Jar for release.
    - Added Rake tasks: `jar`, `runjar`
- Added rough drafts (rough working code) of Lotto, Moka, & Poker bots.

### Changed
- Changed `Config` to allow non-Tab message keys.
- Changed to use `SSC.Bot` Gem, instead of internal (old) code for working with Subspace Continuum. For `SSC.Bot`, I basically extracted all of this code, updated it, and put it under a more permissible license (LGPL).
- Updated Gems.
- Formatted all files.
- Formatted all code with RuboCop.
- Updated Readme to reflect new changes.


## [v0.1.0] - 2020-04-30

Initial working version.

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
