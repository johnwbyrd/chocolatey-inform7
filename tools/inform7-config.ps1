# Shared configuration for Inform 7 Chocolatey package
# This file defines the common values used across install and uninstall scripts

# Files to create shims for (both paths relative to installation root)
$script:Inform7ShimFiles = @{
    # Format: Key = relative path to executable, Value = whether it's a GUI app
    "Inform.exe"            = $true         # GUI app in root directory
    "Compilers\inform6.exe" = $false
    "Compilers\inform7.exe" = $false
    "Compilers\inblorb.exe" = $false
    "Compilers\intest.exe"  = $false
}

# Function to get just the base names of files (for easier use with Install-BinFile)
function Get-Inform7ShimBaseNames {
    $Inform7ShimFiles.Keys | ForEach-Object {
        [System.IO.Path]::GetFileNameWithoutExtension($_)
    }
} 