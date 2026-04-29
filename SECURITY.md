# Security Policy

## Important Notice

The Speculator installer runs with `sudo` privileges. It modifies system packages, installs software and changes GNOME desktop settings. Review the full contents of `speculator_install.sh` before running it on any system.

## Reporting Vulnerabilities

If you discover a security vulnerability, open a GitHub issue with a description of the problem and steps to reproduce it. We will respond as quickly as possible.

## Credential Handling

The Speculator Project does not store passwords, API keys or other credentials. Tools that require API keys (such as Shodan, Censys or h8mail) are configured individually by the user after installation. No secrets are written to configuration files by the installer.

## Disclaimer

This software is provided as-is, without warranty of any kind. It is intended for educational and lawful testing purposes only. You are responsible for reviewing the code and understanding what it does before running it on your system.
