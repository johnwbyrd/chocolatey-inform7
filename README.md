# Chocolatey Package for Inform 7

This repository contains a Chocolatey package for Inform 7, a programming language for creating interactive fiction using natural language syntax.

## What is Inform 7?

Inform 7 is a design system for interactive fiction based on natural language. It's designed to be accessible to writers and others who don't have a programming background. The language reads like English prose, making it uniquely approachable for creating text-based games and stories.

## About this Package

This Chocolatey package installs Inform 7 version 10.1.2 for Windows. It automatically downloads the official distribution from the Inform GitHub repository and installs it using standard silent installation parameters.

## Installation

To install Inform 7 using this package:

```powershell
choco install inform7
```

To upgrade an existing installation:

```powershell
choco upgrade inform7
```

To uninstall:

```powershell
choco uninstall inform7
```

## Development and Testing

### Local Development

To build and test this package locally:

1. Clone this repository
2. Make any necessary changes to the package files
3. Build the package:
   ```powershell
   choco pack
   ```
4. Test the package installation:
   ```powershell
   choco install inform7 -dv -s .
   ```
5. Test the package uninstallation:
   ```powershell
   choco uninstall inform7 -dv
   ```

The `-dv` flag enables debug and verbose output, which is helpful for diagnosing issues during development.

### CMake Workflow

This repository includes a CMake-based workflow for automating the build, test, and publish process:

#### Prerequisites

- CMake 3.14 or higher
- Chocolatey installed and configured

#### Setting Up

1. Configure the project:
   ```powershell
   cmake -B build
   ```

2. Setting the Chocolatey API Key:
   - For local development:
     ```powershell
     $env:CHOCOLATEY_API_KEY = "your-api-key-here"
     ```
   - For CI/CD, set it as a secret in your GitHub repository

#### Available Targets

Run any of these targets individually or use `all_steps` to run the complete workflow:

```powershell
# Build the project
cmake --build build --target pack

# Verify the package for errors and warnings
cmake --build build --target verify

# Install the package locally
cmake --build build --target choco_install

# Uninstall the package
cmake --build build --target choco_uninstall

# Push the package to Chocolatey.org (requires API key)
cmake --build build --target push

# Run the full workflow (build→verify→install→uninstall)
cmake --build build --target all_steps
```

### Test Scenarios

When testing the package, verify:

- Installation completes successfully
- Inform 7 application launches properly
- Uninstallation removes all package components
- Upgrading from a previous version works correctly

### Troubleshooting

If you encounter issues during testing:
- Check the chocolatey logs (typically in `%PROGRAMDATA%\chocolatey\logs\`)
- Run commands with `-dv` flag for detailed output
- Verify the installer and uninstaller exit codes

### Updating the Package

When a new version of Inform 7 is released:

1. Update the version number in `inform7.nuspec`
2. Update the download URL in `tools/chocolateyinstall.ps1`
3. Update the checksum in `tools/chocolateyinstall.ps1` (use `Get-FileHash` to generate)
4. Test the updated package
5. Submit the updated package to the Chocolatey community repository

## Continuous Integration

This project uses GitHub Actions for continuous integration and deployment.

### GitHub Actions Workflow

The `.github/workflows/chocolatey-build.yml` file contains the CI/CD pipeline configuration:

- **Trigger conditions**: 
  - Push to `main` branch
  - Push tags starting with `v`
  - Pull requests to `main`
  - Manual workflow dispatch

- **Workflow steps**:
  1. Set up a Windows environment
  2. Install Chocolatey
  3. Configure CMake
  4. Build and test the package (`all_steps` target)
  5. Publish to Chocolatey.org (only on `main` branch or tag push)

### Setting up GitHub Actions

To enable automated builds and publishing:

1. Fork or clone this repository
2. Go to your repository's Settings → Secrets → Actions
3. Add a new repository secret named `CHOCOLATEY_API_KEY` with your Chocolatey API key
4. Push to the `main` branch or create a tag to trigger a build and publish

The API key is securely handled throughout the build process. The `push` target automatically registers your API key with Chocolatey before pushing the package.

## Publishing to Chocolatey

### Prerequisites

Before submitting a package to Chocolatey:

1. Create a Chocolatey account at [https://community.chocolatey.org/account/register](https://community.chocolatey.org/account/register)
2. Get your API key from your Chocolatey account page
3. Set up your API key locally:
   ```powershell
   choco apikey --key your-api-key --source https://push.chocolatey.org/
   ```

### Submission Process

To submit a new package or update an existing one:

1. Ensure all tests pass and the package works correctly
2. Run the package validator:
   ```powershell
   choco pack
   choco push --source=https://push.chocolatey.org/ --api-key your-api-key
   ```

After submission:
1. Chocolatey moderators will review the package
2. You may be contacted for additional changes 
3. Once approved, the package will be available in the Chocolatey Community Repository

### Updating Published Packages

For updating already published packages:

1. Update the version number in `inform7.nuspec`
2. Update any other necessary files
3. Build and test thoroughly
4. Push the updated package:
   ```powershell
   choco pack
   choco push --source=https://push.chocolatey.org/
   ```

## License

Inform 7 is released under its own license, which can be found at the [official repository](https://github.com/ganelson/inform/blob/master/LICENSE).

## Links

- [Inform Project Website](https://ganelson.github.io/inform-website/)
- [Inform GitHub Repository](https://github.com/ganelson/inform)
- [Inform Documentation](https://ganelson.github.io/inform-website/doc/)
- [Chocolatey Package Guidelines](https://docs.chocolatey.org/en-us/create/create-packages)
- [Chocolatey Community Repository](https://community.chocolatey.org/packages) 