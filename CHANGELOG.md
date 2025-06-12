# Changelog

All notable changes to the SSL Certificate Manager script will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2024-12-06

### Added
- **System Certificate Cleanup**: New menu option 5 "System certificate cleanup"
- List and remove certificates from original system paths:
  - Certbot certificates from `/etc/letsencrypt/live/`
  - ACME.sh certificates from `~/.acme.sh/`
- Certificate expiry date display for system certificates
- Smart removal using native tools (certbot delete, acme.sh --remove) with fallback to manual removal
- Comprehensive certificate information display (paths, expiry dates)
- Safe removal with confirmation prompts

### Changed
- Main menu now has 7 options (was 6)
- Menu selection prompt updated to "Select an option (1-7)"
- Exit option moved to option 7

### Improved
- Better certificate management workflow for failed certificate creation scenarios
- Enhanced cleanup capabilities for troubleshooting certificate issues
- More detailed certificate information display

## [1.1.0] - 2024-12-06

### Added
- **Auto-Update Feature**: Added option 5 "Check for script updates" to main menu
- Version comparison logic to detect newer versions
- Automatic script download and replacement functionality
- Backup creation before updating (timestamped backups)
- Update confirmation prompt with user choice
- Error handling for network issues during update check

### Changed
- Main menu now has 6 options (was 5)
- Menu selection prompt updated to "Select an option (1-6)"

### Improved
- Enhanced version management with semantic version comparison
- Safe update process with automatic backup creation
- User-friendly update notifications and prompts

## [1.0.2] - 2024-12-06

### Removed
- Removed domain validation entirely - let certificate tools (acme.sh/certbot) handle domain validation
- Only checks if domain input is not empty

### Fixed
- Fixed domain input issues that were blocking valid domains like `mzpanel.bime.info`
- Simplified domain handling for better reliability

## [1.0.1] - 2024-12-06

### Changed
- Removed interactive prompt after dependency check completion
- Script now automatically proceeds to main menu after dependency installation
- Reduced wait time from user input to 1-second automatic pause

### Fixed
- Fixed domain validation regex to properly support subdomains (e.g., `mzpanel.bime.info`)
- Fixed domain validation to support multi-level domains

### Improved
- Better user experience with smoother flow from dependency check to main menu
- More reliable domain format validation

## [1.0.0] - 2024-12-06

### Added
- Initial release of SSL Certificate Manager for Marzneshin
- Interactive SSL certificate management interface
- Support for both acme.sh and certbot certificate methods
- Email input with memory (remembers and suggests last used email)
- Domain name validation with support for subdomains
- Path history management (remembers last 10 used paths)
- Certificate registry to track all created certificates
- Certificate listing functionality with status checking
- Certificate removal functionality with confirmation
- Automatic dependency installation (curl, wget, socat, cron)
- Colorized output for better user experience
- Domain-named certificate files (e.g., `example.com.crt`, `example.com.key`)
- Command line options: `--version` and `--help`
- Comprehensive error handling and validation
- Port availability checking (80 and 443)
- System package updates before installation
- Configuration directory management (`~/.ssl-cert-manager/`)

### Features
- **Two Certificate Methods**:
  - acme.sh method (recommended): Lightweight and flexible
  - certbot method: Official Let's Encrypt client
- **Smart Path Selection**: Choose from recent paths or enter custom path
- **Certificate Management**: List, track, and remove certificates
- **Email Memory**: Automatically suggests previously used email
- **Domain Validation**: Supports all valid domain formats including subdomains
- **Automatic Setup**: Installs all required dependencies automatically
- **Interactive Interface**: User-friendly colorized interface
- **Error Handling**: Comprehensive validation and error messages

### Technical Details
- Bash script compatible with Ubuntu/Debian systems
- Requires root access for system operations
- Stores configuration in `~/.ssl-cert-manager/`
- Supports semantic versioning for easy maintenance
- Follows security best practices for certificate management

---

## Version Format

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes or major rewrites
- **MINOR**: New features, significant improvements  
- **PATCH**: Bug fixes, small improvements

## Categories

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes
- **Improved**: Performance or usability improvements