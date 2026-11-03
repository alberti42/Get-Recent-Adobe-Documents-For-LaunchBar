# Changelog

All notable changes to the Get Recent Adobe Documents actions are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-11-03

### Fixed

- The actions showed no documents on Macs with System Integrity Protection enabled: macOS killed the tools, which carried no code signature. The tools are now signed with a Developer ID and notarized by Apple.

### Changed

- The actions require macOS 12 or later.
- `Actions.zip` is attached to each GitHub release, with a build provenance attestation, instead of being kept in the repository.

[Unreleased]: https://github.com/alberti42/Get-Recent-Adobe-Documents-For-LaunchBar/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/alberti42/Get-Recent-Adobe-Documents-For-LaunchBar/compare/1.0.0...v2.0.0
