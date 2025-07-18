# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-07-18

### Added
- Initial release of Universal Certificate Chain Extractor
- PowerShell script for automatic certificate chain extraction
- Windows batch file launcher for easy usage
- Automatic CA certificate detection and filtering
- Mac-compatible PEM format conversion
- Generated installation guides with step-by-step instructions
- Support for any HTTPS server with certificate chains
- Connection testing and error handling
- Comprehensive documentation and examples

### Features
- Extracts complete certificate chains from any HTTPS server
- Identifies and separates Certificate Authority certificates from server certificates
- Converts certificates to macOS-compatible PEM format
- Generates detailed installation instructions for macOS Keychain
- Provides both GUI and command-line interfaces
- Includes troubleshooting guidance and alternative installation methods
- Works with enterprise applications, development servers, and IoT devices

### Supported Use Cases
- Internal company websites with private Certificate Authorities
- Development and staging environments with self-signed certificates
- Enterprise applications (SAS, GitLab, Jenkins, etc.)
- IoT devices and network equipment with custom certificates
- Any HTTPS endpoint causing certificate chain validation errors on macOS
