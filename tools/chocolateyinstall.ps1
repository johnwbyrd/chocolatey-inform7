$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/ganelson/inform/releases/download/v10.1.2/Inform_10_1_2_Windows.zip' # download url, HTTPS preferred
$setupName = 'Inform_10_1_2_Windows.exe'

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    unzipLocation  = $toolsDir
    fileType       = 'EXE' #only one of these: exe, msi, msu
    url            = $url

    softwareName   = 'Inform *'

    checksum       = '4DC80A37CF9DE1C0FFA9FD4B9E9BAD93479E844D4A1BE19DAC17BEC38BE63CBA'
    checksumType   = 'sha256'
    silentArgs     = '/S'           # NSIS
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

# Standard installation directory for Inform
$inform7InstallDir = Join-Path $env:ProgramFiles "Inform"
$compilerDir = Join-Path $inform7InstallDir "Compilers"

# Function to create a shim with error handling
function Create-Inform7Shim {
    param (
        [string]$Name,
        [string]$Path
    )
    
    if (Test-Path $Path) {
        Write-Output -InputObject "Creating shim for $Name at $Path"
        Install-BinFile -Name $Name -Path $Path
    } else {
        Write-Warning "Executable not found at $Path - shim for $Name was not created."
    }
}

# Create shims for the compiler executables with proper error handling
Create-Inform7Shim -Name "inblorb" -Path (Join-Path $compilerDir "inblorb.exe")
Create-Inform7Shim -Name "inform6" -Path (Join-Path $compilerDir "inform6.exe")
Create-Inform7Shim -Name "inform7" -Path (Join-Path $compilerDir "inform7.exe")
Create-Inform7Shim -Name "intest" -Path (Join-Path $compilerDir "intest.exe")

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
