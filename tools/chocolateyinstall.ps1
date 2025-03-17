$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://github.com/ganelson/inform/releases/download/v10.1.2/Inform_10_1_2_Windows.zip' # download url, HTTPS preferred
$setupName  = 'Inform_10_1_2_Windows.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'EXE' #only one of these: exe, msi, msu
  url           = $url
  url64bit      = $url64

  softwareName  = 'Inform *'

  checksum      = '4DC80A37CF9DE1C0FFA9FD4B9E9BAD93479E844D4A1BE19DAC17BEC38BE63CBA'
  checksumType  = 'sha256'
  silentArgs   = '/S'           # NSIS
  validExitCodes= @(0) 
}


Install-ChocolateyZipPackage @packageArgs # https://docs.chocolatey.org/en-us/create/functions/install-chocolateyzippackage

$packageArgs.file = Join-Path -Path $toolsDir -ChildPath $setupName
Install-ChocolateyInstallPackage @packageArgs
