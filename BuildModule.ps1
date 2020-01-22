$ModuleConfig = @{
    "Path" = ".\pwsh-releasesapi\pwsh-releasesapi.psd1";
    "Guid" = "23809952-e65d-495b-b263-b01971687a3c";
    "Author" = "Timothy Small";
    "CompanyName" = "Smalls.Online"
    "Copyright" = "2020";
    "RootModule" = "pwsh-releasesapi.psm1";
    "ModuleVersion" = "2001.01";
    "Description" = "Get all of the current releases of PowerShell Core from the GitHub API."
    "FunctionsToExport" = @("Get-PwshReleases")
}

$PathTest = Test-Path -Path $ModuleConfig['Path']

switch ($PathTest) {
    $false {
        New-ModuleManifest @ModuleConfig
    }

    Default {
        Update-ModuleManifest @ModuleConfig
    }
}