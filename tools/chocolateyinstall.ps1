# Inform 7 Installation Script
# 
# This script performs the following operations:
# 1. Determines the installation location based on package parameters or defaults
# 2. Downloads and installs Inform 7 application
# 3. Sets environment variables to allow integration with other tools
# 4. Configures selective shimming to ensure only executables in the root and
#    Compilers directories are available on the PATH

$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Import shared configuration
. (Join-Path $toolsDir "inform7-config.ps1")

$url = 'https://github.com/ganelson/inform/releases/download/v10.1.2/Inform_10_1_2_Windows.zip'
$setupName = 'Inform_10_1_2_Windows.exe'

# Get package parameters to determine installation location
$pp = Get-PackageParameters

# Determine if we're using a custom location
$usingCustomLocation = $null -ne $pp.InstallLocation

if ($pp.InstallLocation) {
    $inform7InstallDir = $pp.InstallLocation
    Write-Host "Using package parameter specified installation directory: $inform7InstallDir"
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
    silentArgs     = "/S /D=$inform7InstallDir"  # For NSIS, /D= must be the last parameter
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

$shimCount = 0
$ignoreCount = 0
$manualShimCount = 0

# Apply shimming based on the configuration file
foreach ($exePath in $Inform7ShimFiles.Keys) {
    $isGui = $Inform7ShimFiles[$exePath]
    $fullPath = Join-Path $inform7InstallDir $exePath
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($exePath)
    
    if (Test-Path $fullPath) {
        # Create .gui or .ignore files based on configuration
        if ($isGui) {
            New-Item "$fullPath.gui" -Type File -Force | Out-Null
            Write-Host "Creating GUI shim for $baseName"
        } else {
            Write-Host "Creating console shim for $baseName"
        }
        
        # For custom locations, also create manual shims
        if ($usingCustomLocation) {
            Install-BinFile -Name $baseName -Path $fullPath
            Write-Host "Created manual shim for $baseName using Install-BinFile"
            $manualShimCount++
        }
        
        $shimCount++
    } else {
        Write-Warning "File $fullPath not found, skipping shim creation"
    }
}

# Now identify and mark all other executables with .ignore to prevent shimming
Write-Host "Finding all other executables in the installation directory..."
$allExes = Get-ChildItem $inform7InstallDir -Include *.exe -Recurse
foreach ($exe in $allExes) {
    $exePath = $exe.FullName
    $relativePath = $exePath.Substring($inform7InstallDir.Length + 1)
    
    # If this file is not in our configured shim list, ignore it
    if (-not $Inform7ShimFiles.ContainsKey($relativePath)) {
        New-Item "$exePath.ignore" -Type File -Force | Out-Null
        Write-Host "Preventing shim for $relativePath"
        $ignoreCount++
    }
}

$summaryMessage = "Selective shimming complete. Created $shimCount shims, ignored $ignoreCount executables."
if ($usingCustomLocation) {
    $summaryMessage += " Created $manualShimCount manual shims for custom installation location."
}
Write-Host $summaryMessage

Write-Output "Inform 7 installation completed successfully."
 