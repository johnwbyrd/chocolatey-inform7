# Chocolatey Package for Inform 7

This repository contains a Chocolatey package for [Inform 7](https://inform7.com/), a design system for interactive fiction. 

## Project Overview

This package automates the installation of Inform 7 on Windows systems through the Chocolatey package manager. It downloads the official distribution from the Inform GitHub repository and performs a silent installation.

## Enhanced Features

The package includes these enhanced features for better usability:

### Command-Line Shims

Shims for the Inform compiler executables are automatically created in the Chocolatey bin folder:
- `inform7.exe` - Main Inform 7 compiler
- `inform6.exe` - Inform 6 compiler used by Inform 7
- `inblorb.exe` - Blorb packager for Inform stories
- `intest.exe` - Inform testing tool

These shims allow you to run the Inform tools from any command line without needing to add the installation directory to your PATH.

### Environment Variables

Two environment variables are automatically set to help locate Inform components:
- `INFORM_HOME` - Points to the root Inform installation directory (typically `C:\Program Files\Inform`)
- `INFORM7_INTERNAL` - Points to the Internal directory within the Inform installation

These variables can be used by other tools, scripts, or build systems that need to locate the Inform installation.

### Custom Installation Directory

You can specify a custom installation directory when installing the package:

```powershell
choco install inform7 --params "'/D:C:\custom\path'"
```

If no directory is specified, Chocolatey will install Inform 7 to the default tools location, typically:
- `$env:ChocolateyToolsLocation\Inform` (determined by Chocolatey)

This allows you to control where the software is installed without modifying the package itself.

## Repository Structure

- `inform7.nuspec`: Package metadata including version, description, and URLs
- `tools/`: Chocolatey scripts
  - `chocolateyinstall.ps1`: Installation script
  - `chocolateyuninstall.ps1`: Uninstallation script
- `CMakeLists.txt`: Build system for testing and publishing
- `cmake/`: CMake helper scripts
- `.github/workflows/`: CI/CD configuration

## Local Development Workflow

### Prerequisites

- CMake 3.14 or higher
- Chocolatey installed
- PowerShell

### Important: Administrator Rights Required

**You must launch VS Code or Cursor with administrator privileges** when performing local installations or uninstallations of the package. This is required because:

- Installing/uninstalling Chocolatey packages requires admin rights
- Environment variables are set at the system level
- Files are installed to protected directories

To start VS Code/Cursor with admin rights:
1. Right-click on the application icon
2. Select "Run as administrator"
3. Confirm the UAC prompt

Failure to run with admin rights will result in permission errors during package installation/uninstallation.

### Build Targets

The CMake build system provides several targets:

#### Individual Targets

- `pack`: Builds the .nupkg package
- `verify`: Validates the package for errors and warnings
- `choco_install`: Installs the package locally
- `choco_uninstall`: Uninstalls the package
- `push`: Pushes the package to Chocolatey.org (requires API key)

#### Workflow Targets

- `test_package`: Runs the full test cycle (build→verify→install→uninstall)
- `all_steps`: Complete workflow including publishing

### Development Cycle

1. Configure the project:
   ```powershell
   cmake -B build
   ```

2. Test the package:
   ```powershell
   cmake --build build --target test_package
   ```

3. For publishing, set the API key:
   ```powershell
   $env:CHOCOLATEY_API_KEY = "your-api-key-here"
   ```

4. Publish the package:
   ```powershell
   cmake --build build --target push
   ```

### Updating the Package

When a new version of Inform 7 is released:

1. Update the version and release notes in `inform7.nuspec`
2. Update the download URL in `tools/chocolateyinstall.ps1`
3. Calculate the checksum:
   ```powershell
   # Download the file first
   Invoke-WebRequest -Uri <new-download-url> -OutFile installer.zip
   # Generate SHA256 checksum
   Get-FileHash installer.zip -Algorithm SHA256
   ```
4. Update the checksum in `tools/chocolateyinstall.ps1`
5. Test thoroughly before publishing

## CI/CD with GitHub Actions

This repository uses GitHub Actions to automate testing and publishing.

### Workflow Overview

The workflow in `.github/workflows/chocolatey-build.yml` contains:

- **Build Job**: 
  - Runs on all branches and PRs
  - Installs CMake and Ninja
  - Runs the `test_package` target to test the package

- **Publish Job**:
  - Only runs on `main` branch or tag pushes
  - Uses a protected `production` environment
  - Runs the `push` target to publish to Chocolatey

### Setting Up the Environment

1. Go to your repository's Settings → Environments
2. Create a new environment named `production`
3. Under "Deployment branches", select "Selected branches"
4. Add a rule to limit to the `main` branch
5. Optionally add required reviewers

### Setting Up the API Key

1. Go to your repository's Settings → Environments → production
2. Under "Environment secrets", add a new secret:
   - Name: `CHOCOLATEY_API_KEY`
   - Value: Your Chocolatey API key

### Triggering the Workflow

The workflow runs automatically on:
- Pushes to the `main` branch
- Tag pushes starting with `v`
- Pull requests (testing only)

You can also manually trigger it through the Actions tab in GitHub.

## Testing

When testing the package, verify:

- Installation completes without errors
- The Inform 7 application launches correctly
- Command-line shims work correctly (test by running `inform7 --help` in a command prompt)
- Environment variables are set correctly (verify with `echo %INFORM_HOME%` and `echo %INFORM7_INTERNAL%`)
- Uninstallation removes all components, shims, and environment variables
- Upgrading from previous versions works correctly

### Troubleshooting

- Check Chocolatey logs: `%PROGRAMDATA%\chocolatey\logs\`
- Use the `-dv` flag for verbose output
- Run commands with administrator privileges
- If shims don't work, check if the executables exist in the specified paths

## Publishing Process

### Automated Publishing

The GitHub Actions workflow will automatically publish when:
1. A commit is pushed to the `main` branch
2. A tag starting with `v` is pushed

### Manual Publishing

For manual publishing:
1. Obtain a Chocolatey API key
2. Set it in your environment or directly in CMake
3. Run the publish command:
   ```powershell
   cmake --build build --target push
   ```

### Chocolatey Moderation

After submission:
1. Chocolatey moderators will review the package
2. You may be contacted for changes
3. Once approved, it becomes available in the Chocolatey repository

## License & Links

- Inform 7 is released under its [own license](https://github.com/ganelson/inform/blob/master/LICENSE)
- [Inform Project Website](https://ganelson.github.io/inform-website/)
- [Inform GitHub Repository](https://github.com/ganelson/inform)
- [Chocolatey Documentation](https://docs.chocolatey.org/) 