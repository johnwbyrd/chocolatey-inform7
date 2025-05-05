# Chocolatey Package for Inform 7

This repository contains a Chocolatey package for [Inform 7](https://inform7.com/), a design system for interactive fiction.

## Introduction

This package automates the installation of Inform 7 on Windows systems through the Chocolatey package manager. It downloads the official distribution from the Inform GitHub repository and performs a silent installation with additional enhancements for developer convenience.

## Package Features

The package includes several enhancements beyond basic installation:

- **Selective Command-Line Shims**: Creates shims for executables in the root and Compilers directories, making them available from any command line without modifying your PATH
- **Environment Variables**: Sets up `INFORM7_HOME` and `INFORM7_INTERNAL` variables to help other tools locate the Inform installation
- **Custom Installation Directory**: Allows specifying a non-default installation location

## Installation

Basic installation:

```powershell
choco install inform7
```

With custom installation directory:

```powershell
choco install inform7 --ia "/D:C:\custom\path"
```

If no directory is specified, Chocolatey will install Inform 7 to the default Chocolatey location, typically `$env:ChocolateyToolsLocation\inform7`.

## Usage

### Running Inform 7

After installation, you can launch Inform 7 from the Start Menu or the installed location.

### Command-Line Tools

The following executables from the root and Compilers directories are automatically available from any command line:

```powershell
# Check if a command-line tool is available
inform
inform7 --help
inform6 --help
inblorb --help
intest --help
```

### Environment Variables

Access Inform 7 locations in scripts or other tools:

```powershell
# Access environment variables
echo %INFORM7_HOME%
echo %INFORM7_INTERNAL%
```

## Development Guide

### Development Prerequisites

- CMake 3.14 or higher
- Chocolatey
- PowerShell
- Ninja

### Administrator Rights

**Administrator privileges are required** when testing or developing this package as it:
- Installs/uninstalls Chocolatey packages
- Sets system-level environment variables
- Modifies protected directories

Start your development environment with admin rights:
1. Right-click on your editor/IDE
2. Select "Run as administrator"
3. Confirm the UAC prompt

Alternatively, use cmake at a command prompt with administrator rights for development and
testing.

### Development Workflow

The CMake build system provides several targets:

```powershell
# Configure the project
cmake -B build -G Ninja

# Test the full package installation cycle
cmake --build build --target test_package

# Individual operations are also available:
# - pack: Build the package
# - verify: Check package for errors
# - choco_install: Build, verify, install locally
# - choco_uninstall: Build, verify, install locally, uninstall
# - choco_uninstall_no_dependencies: Uninstall without installing first
# - push: Publish to Chocolatey.org
# - all_tests: Run the entire build/install/uninstall/push cycle
```

### Updating for New Releases

When a new version of Inform 7 is released:

1. Update version and release notes in `inform7.nuspec`
2. Update download URL in `tools/chocolateyinstall.ps1`
3. Calculate and update the SHA256 checksum:
   ```powershell
   Invoke-WebRequest -Uri <new-download-url> -OutFile installer.zip
   Get-FileHash installer.zip -Algorithm SHA256
   ```
4. Test thoroughly before publishing

## CI/CD Workflow

This repository uses GitHub Actions to automate testing and publishing.

### Setting Up the Environment

1. Create a `production` environment in repository Settings
2. Limit it to the `main` branch
3. Add the `CHOCOLATEY_API_KEY` secret

### Workflow Process

The workflow in `.github/workflows/chocolatey-build.yml`:
- Runs tests on all branches and PRs
- Publishes only from `main` branch or tag pushes
- Uses the protected `production` environment for publishing

### Triggering Workflows

The workflow runs automatically on:
- Pushes to the `main` branch
- Tag pushes starting with `v`
- Pull requests (testing only)

## Testing

Verify the following during testing:

- Installation completes without errors
- Inform 7 application launches correctly
- Command-line shims for root and Compilers executables work correctly
- Environment variables are set correctly
- Uninstallation removes all components
- Upgrading from previous versions works correctly

### Troubleshooting

- Check Chocolatey logs: `%PROGRAMDATA%\chocolatey\logs\`
- Use `-dv` flag for verbose output: `choco install inform7 -dv`
- If shims don't work, verify the executables exist and are not in ignored locations

## Publishing

### Automated Publishing

GitHub Actions automatically publishes when:
- A commit is pushed to the `main` branch
- A tag starting with `v` is pushed

### Manual Publishing

For manual publishing:
```powershell
# Set your API key
$env:CHOCOLATEY_API_KEY = "your-api-key-here"

# Build and publish
cmake --build build --target push
```

### Chocolatey Moderation

After submission:
1. Chocolatey moderators review the package
2. You may be contacted for changes
3. Once approved, it becomes available in the Chocolatey repository

## References

- Inform 7 is released under its [own license](https://github.com/ganelson/inform/blob/master/LICENSE)
- [Inform Project Website](https://ganelson.github.io/inform-website/)
- [Inform GitHub Repository](https://github.com/ganelson/inform)
- [Chocolatey Documentation](https://docs.chocolatey.org/) 