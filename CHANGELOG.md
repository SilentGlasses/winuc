# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [1.1.0] - 2025-10-27

### Added

- Issue Templates for Bug Reports, Feature Requests and Pull Requests.
- Workflow to create the auto generate the `autounattend.xml` file but only when a PR introduces changes to bypass settings.

### Changed

- Cleaned up the utility to remove extraneous comments.

## [1.0.0] - 2025-09-26

### Added
- Initial release of Windows Ultimate Configurator
- Windows 11 hardware requirement bypasses _(TPM 2.0, Secure Boot, CPU, RAM, Storage)_
- Privacy enhancements _(disable telemetry, Cortana, location services, advertising ID)_
- Security enhancements _(Windows Defender, UAC, Firewall, SmartScreen)_
- Performance optimizations _(visual effects, startup delay, CPU priority, search indexing)_
- Gaming optimizations _(disable Game DVR, Game Mode, fullscreen optimizations, GPU scheduling)_
- Network enhancements _(disable Windows Update P2P, Cloudflare DNS, optimize throttling)_
- System cleanup options _(remove Xbox apps, disable OneDrive, clean temp files)_
- Appearance tweaks _(classic context menu, left-align taskbar, show file extensions)_
- Two operation modes: Apply directly or Generate `autounattend.xml`
- Registry modification with proper error handling
- Support for both `DWORD` and `String` registry types
