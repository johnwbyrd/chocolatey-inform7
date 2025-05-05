# Inform 7 Installation Script
# 
# This script performs the following operations:
# 1. Determines the installation location based on user parameters or defaults
# 2. Downloads and installs Inform 7 application
# 3. Sets environment variables to allow integration with other tools
# 4. Configures selective shimming to ensure only executables in the root and
#    Compilers directories are available on the PATH

$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/ganelson/inform/releases/download/v10.1.2/Inform_10_1_2_Windows.zip'
$setupName = 'Inform_10_1_2_Windows.exe'

# Determine installation location based on user parameters or Chocolatey defaults
$pp = Get-PackageParameters

if ($pp.ContainsKey('D')) {
    $inform7InstallDir = $pp['D']
    Write-Host "Using user-specified installation directory: $inform7InstallDir"
} else {
    $packagePath = Get-ChocolateyPath PackagePath
    $inform7InstallDir = $packagePath
    Write-Host "Using Chocolatey default installation directory: $inform7InstallDir"
}

# Ensure parent directory exists before installation
$parentDir = Split-Path -Parent $inform7InstallDir
if (-not (Test-Path $parentDir)) {
    Write-Host "Creating parent directory $parentDir"
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}

# Package installation parameters for NSIS installer
$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    unzipLocation  = $toolsDir
    fileType       = 'EXE'
    url            = $url

    softwareName   = 'Inform *'

    checksum       = '4DC80A37CF9DE1C0FFA9FD4B9E9BAD93479E844D4A1BE19DAC17BEC38BE63CBA'
    checksumType   = 'sha256'
    silentArgs     = "/S /D=$inform7InstallDir"
    validExitCodes = @(0) 
}

# Extract the installer from the ZIP archive
Write-Host "Downloading and extracting Inform 7 installer..."
Install-ChocolateyZipPackage @packageArgs

# Run the installer with the specified parameters
Write-Host "Installing Inform 7..."
$packageArgs.file = Join-Path -Path $toolsDir -ChildPath $setupName
Install-ChocolateyInstallPackage @packageArgs

# Set environment variables for integration with external tools and scripts
Write-Host "Setting up Inform environment variables..."

$internalDir = Join-Path $inform7InstallDir "Internal"

try {
    Install-ChocolateyEnvironmentVariable -VariableName "INFORM7_HOME" -VariableValue $inform7InstallDir -VariableType 'Machine'
    Write-Host "Environment variable INFORM7_HOME set to $inform7InstallDir"
    
    if (Test-Path $internalDir) {
        Install-ChocolateyEnvironmentVariable -VariableName "INFORM7_INTERNAL" -VariableValue $internalDir -VariableType 'Machine'
        Write-Host "Environment variable INFORM7_INTERNAL set to $internalDir"
    } else {
        Write-Warning "Internal directory not found at $internalDir - INFORM7_INTERNAL environment variable was not set."
    }
} catch {
    Write-Warning "Failed to set environment variables: $_"
    Write-Warning "This may occur if the script is not running with administrative privileges."
}

Write-Host "Inform 7 environment variables set."

# Configure selective shimming for executables
Write-Host "Setting up selective shimming for Inform7..."

Write-Host "Inform7 installation directory: $inform7InstallDir"

# Identify directories where executables should be shimmed
$rootDir = $inform7InstallDir
$compilersDir = Join-Path $inform7InstallDir "Compilers"

Write-Host "Finding all executables in the installation directory..."
$allExes = Get-ChildItem $inform7InstallDir -Include *.exe -Recurse

# Apply .ignore files to prevent shimming of executables not in allowed directories
# and .gui files to properly handle GUI applications
Write-Host "Applying .ignore files to control shimming..."
foreach ($exe in $allExes) {
    $exePath = $exe.FullName
    $exeDir = Split-Path $exePath -Parent
    
    if ($exeDir -ne $rootDir -and $exeDir -ne $compilersDir) {
        Write-Host "Creating .ignore file for $exePath"
        New-Item "$exePath.ignore" -Type File -Force | Out-Null
    } else {
        Write-Host "Allowing shim for $exePath"
        
        # Detect GUI applications and create appropriate .gui files
        try {
            $binaryType = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($exePath).FileType
            if ($binaryType -eq "Application") {
                Write-Host "Creating .gui file for $exePath"
                New-Item "$exePath.gui" -Type File -Force | Out-Null
            }
        } catch {
            Write-Host "Could not determine if $exePath is a GUI app. Treating as console app."
        }
    }
}

Write-Host "Selective shimming setup completed."
Write-Output "Inform 7 installation completed successfully."
