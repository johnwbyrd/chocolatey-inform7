# Inform 7 Uninstallation Script
#
# This script performs the following operations:
# 1. Detects the Inform 7 installation from the Windows registry
# 2. Runs the application's uninstaller with silent parameters
# 3. Cleans up environment variables created during installation
# 4. Cleans up any manual shims created during installation
# 5. Allows Chocolatey to automatically handle shim removal
# 6. Performs final cleanup operations

$ErrorActionPreference = 'Stop'

# Locate the application's uninstaller through registry entries
$softwareName = 'Inform *'
$validExitCodes = @(0, 3010, 1605, 1614, 1641)

[array]$key = Get-UninstallRegistryKey -SoftwareName $softwareName

# Run the application's uninstaller if found, with appropriate error handling
if ($key.Count -eq 1) {
    $key | ForEach-Object {
        $packageArgs = @{
            packageName    = $env:ChocolateyPackageName
            softwareName   = $softwareName
            fileType       = 'EXE'
            silentArgs     = '/S'
            validExitCodes = $validExitCodes
            file           = "$($_.UninstallString)"
        }

        Write-Host "Running Inform 7 uninstaller..."
        Uninstall-ChocolateyPackage @packageArgs
    }
} elseif ($key.Count -eq 0) {
    Write-Warning "Inform 7 not found in the registry. The application may have been uninstalled already."
} elseif ($key.Count -gt 1) {
    Write-Warning "Multiple instances of Inform 7 found in the registry. Please uninstall manually."
    Write-Warning "To prevent accidental data loss, no automatic uninstallation will be performed."
}

# Clean up any manual shims created with Install-BinFile
# These need to be cleaned up especially for custom installations
Write-Host "Removing manual shims..."
$binFilesToRemove = @(
    "Inform",
    "inform7",
    "inform6",
    "inblorb",
    "intest"
)

foreach ($binFile in $binFilesToRemove) {
    try {
        Uninstall-BinFile -Name $binFile
        Write-Host "Removed manual shim for $binFile"
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Warning "Could not remove manual shim for $binFile. Error: $errorMessage"
    }
}

# Let Chocolatey handle automatic shim removal
Write-Host "Chocolatey will automatically remove standard shims during uninstallation..."

# Clean up environment variables created during installation
Write-Host "Removing Inform 7 environment variables..."

try {
    Uninstall-ChocolateyEnvironmentVariable -VariableName "INFORM7_HOME" -VariableType 'Machine'
    Write-Host "Environment variable INFORM7_HOME removed"
    
    Uninstall-ChocolateyEnvironmentVariable -VariableName "INFORM7_INTERNAL" -VariableType 'Machine'
    Write-Host "Environment variable INFORM7_INTERNAL removed"
} catch {
    Write-Warning "Failed to remove environment variables. This may occur if the script is not running with administrative privileges."
}

# Perform final cleanup operations
Write-Host "Cleaning up any remaining files..."

Write-Host "Uninstallation complete."
Write-Output "Inform 7 has been successfully uninstalled."