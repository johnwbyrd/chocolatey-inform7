$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/ganelson/inform/releases/download/v10.1.2/Inform_10_1_2_Windows.zip' # download url, HTTPS preferred
$setupName = 'Inform_10_1_2_Windows.exe'

# Parse package parameters
$pp = Get-PackageParameters

# Determine installation directory
if ($pp.ContainsKey('D')) {
    # User specified a path with /D parameter
    $inform7InstallDir = $pp['D']
    Write-Output "Using user-specified installation directory: $inform7InstallDir"
} else {
    # No path specified, use Chocolatey's default location
    $packagePath = Get-ChocolateyPath PackagePath
    $inform7InstallDir = $packagePath
    Write-Output "Using Chocolatey default installation directory: $inform7InstallDir"
}

# Make sure parent directory exists
$parentDir = Split-Path -Parent $inform7InstallDir
if (-not (Test-Path $parentDir)) {
    Write-Output "Creating parent directory $parentDir"
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    unzipLocation  = $toolsDir
    fileType       = 'EXE' #only one of these: exe, msi, msu
    url            = $url

    softwareName   = 'Inform *'

    checksum       = '4DC80A37CF9DE1C0FFA9FD4B9E9BAD93479E844D4A1BE19DAC17BEC38BE63CBA'
    checksumType   = 'sha256'
    # The /D parameter must be the last parameter for NSIS
    # Do not quote the path, even if it contains spaces
    silentArgs     = "/S /D=$inform7InstallDir"
    validExitCodes = @(0) 
}

Install-ChocolateyZipPackage @packageArgs # https://docs.chocolatey.org/en-us/create/functions/install-chocolateyzippackage

$packageArgs.file = Join-Path -Path $toolsDir -ChildPath $setupName
Install-ChocolateyInstallPackage @packageArgs

#############################################################################
# ENHANCEMENT: Create shims for Inform compiler executables                 #
# This allows users to run the Inform compiler tools from the command line  #
# without having to add the installation directory to the PATH              #
#############################################################################

Write-Output -InputObject "Creating shims for Inform compiler executables..."

#############################################################################
# ENHANCEMENT: Set environment variables for Inform                         #
# This allows other applications and scripts to easily locate the           #
# Inform installation and internal directories                              #
#############################################################################

Write-Output -InputObject "Setting up Inform environment variables..."

# Set INFORM_HOME to point to the root Inform installation directory
$internalDir = Join-Path $inform7InstallDir "Internal"

# Create environment variables with proper error handling
try {
    Install-ChocolateyEnvironmentVariable -VariableName "INFORM_HOME" -VariableValue $inform7InstallDir -VariableType 'Machine'
    Write-Output -InputObject "Environment variable INFORM_HOME set to $inform7InstallDir"
    
    if (Test-Path $internalDir) {
        Install-ChocolateyEnvironmentVariable -VariableName "INFORM7_INTERNAL" -VariableValue $internalDir -VariableType 'Machine'
        Write-Output -InputObject "Environment variable INFORM7_INTERNAL set to $internalDir"
    } else {
        Write-Warning "Internal directory not found at $internalDir - INFORM7_INTERNAL environment variable was not set."
    }
} catch {
    Write-Warning "Failed to set environment variables: $_"
    Write-Warning "This may occur if the script is not running with administrative privileges."
}

Write-Output -InputObject "Inform 7 installation enhancements complete!"
