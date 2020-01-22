# PowerShell Core Releases API Caller

This script collects data from the GitHub api for the PowerShell repository and returns the data to the console. This a very rough work-in-progress, but it generates `ReleaseAssets` for Windows, macOS, and generic Linux assets for each release.

## Usage

```powershell
PS /> .\Get-PwshRelease.ps1

Name           : v7.0.0-rc.2 Release of PowerShell
VersionTag     : v7.0.0-rc.2
ReleaseDate    : 1/16/2020 11:35:38 PM
IsPreview      : True
ReleasePageUri : https://github.com/PowerShell/PowerShell/releases/tag/v7.0.0-rc.2
ReleaseAssets  : {PowerShell-7.0.0-rc.2-win-arm32.msix, PowerShell-7.0.0-rc.2-win-arm32.zip, PowerShell-7.0.0-rc.2-win-arm64.msix, PowerShell-7.0.0-rc.2-win-arm64.zip…}

Name           : v7.0.0-rc.1 Release of PowerShell Core
VersionTag     : v7.0.0-rc.1
ReleaseDate    : 12/16/2019 9:37:07 PM
IsPreview      : True
ReleasePageUri : https://github.com/PowerShell/PowerShell/releases/tag/v7.0.0-rc.1
ReleaseAssets  : {PowerShell-7.0.0-rc.1-win-arm32.msix, PowerShell-7.0.0-rc.1-win-arm32.zip, PowerShell-7.0.0-rc.1-win-arm64.msix, PowerShell-7.0.0-rc.1-win-arm64.zip…}

[...]


```