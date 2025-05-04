$ErrorActionPreference = 'Stop' # stop on all errors

#############################################################################
# Uninstall the Inform 7 application                                        #
#############################################################################

# Define the software name pattern to detect the uninstaller
$softwareName = 'Inform *'
$validExitCodes = @(0, 3010, 1605, 1614, 1641)

# Get the uninstaller from the registry
[array]$key = Get-UninstallRegistryKey -SoftwareName $softwareName

if ($key.Count -eq 1) {
    $key | ForEach-Object {
        $packageArgs = @{
            packageName    = $env:ChocolateyPackageName
            softwareName   = $softwareName
            fileType       = 'EXE'
            silentArgs     = '/S' # NSIS
            validExitCodes = $validExitCodes
            file           = "$($_.UninstallString)"
        }

        Write-Output -InputObject "Running Inform 7 uninstaller..."
        Uninstall-ChocolateyPackage @packageArgs
    }
} elseif ($key.Count -eq 0) {
    Write-Warning "Inform 7 not found in the registry. The application may have been uninstalled already."
} elseif ($key.Count -gt 1) {
    Write-Warning "Multiple instances of Inform 7 found in the registry. Please uninstall manually."
    Write-Warning "To prevent accidental data loss, no automatic uninstallation will be performed."
}

#############################################################################
# ENHANCEMENT: Clean up shims created during installation                   #
# This removes the command-line shims created during package installation   #
#############################################################################

Write-Output -InputObject "Removing Inform 7 shims..."

# Function to remove a shim with error handling
function Remove-Inform7Shim {
    param (
        [string]$Name
    )
    
    try {
        Write-Output -InputObject "Removing shim for $Name"
        Uninstall-BinFile -Name $Name
    } catch {
        Write-Warning "Failed to remove shim for $Name. Please check if it exists or remove it manually."
    }
}

# Remove shims for the compiler executables
Remove-Inform7Shim -Name "inblorb"
Remove-Inform7Shim -Name "inform6"
Remove-Inform7Shim -Name "inform7"
Remove-Inform7Shim -Name "intest"

#############################################################################
# ENHANCEMENT: Remove environment variables set during installation         #
# This cleans up the environment variables created during installation      #
#############################################################################

Write-Output -InputObject "Removing Inform 7 environment variables..."

# Remove environment variables with proper error handling
try {
    Uninstall-ChocolateyEnvironmentVariable -VariableName "INFORM_HOME" -VariableType 'Machine'
    Write-Output -InputObject "Environment variable INFORM_HOME removed"
    
    Uninstall-ChocolateyEnvironmentVariable -VariableName "INFORM7_INTERNAL" -VariableType 'Machine'
    Write-Output -InputObject "Environment variable INFORM7_INTERNAL removed"
} catch {
    Write-Warning "Failed to remove environment variables. This may occur if the script is not running with administrative privileges."
}

Write-Output -InputObject "Inform 7 uninstallation and cleanup complete!" 