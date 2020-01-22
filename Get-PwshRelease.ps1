[CmdletBinding()]
param()

begin {

    class Release {
        [string]$Name
        [string]$VersionTag
        [datetime]$ReleaseDate
        [bool]$IsPreview
        [string]$ReleasePageUri
        [ReleaseAsset[]]$ReleaseAssets
    }

    class ReleaseAsset {
        [string]$ReleaseName
        [string]$ReleasePlatform
        [string]$ReleaseArch
        [string]$ReleaseExt
        [string]$ReleaseDownloadUri
    }

    $ReleaseApiPagesRegex = "<(?'apiPageUri'.+\?page=(?'pageNumber'\d{1,}))>; rel=\`"(?'rel'.+)\`""

    $WindowsReleaseRegex = ".+-(?'platform'win)-(?'arch'.+)(?'extensions'(\.tar\.gz|\..{3,4}))"
    $LinuxReleaseRegex = ".+-(?'platform'linux)-(?'arch'(alpine-.+|.+))(?'extensions'(\.tar\.gz|\..{3,4}))"
    $macOSReleaseRegex = ".+-(?'platform'osx)-(?'arch'.+)(?'extensions'(\.tar\.gz|\..{3,4}))"
}

process {
    $ReleasesApiUri = "https://api.github.com/repos/powershell/powershell/releases"

    Write-Verbose "Starting API call to GitHub."
    $ReleasesApiStart = Invoke-WebRequest -UseBasicParsing -Uri $ReleasesApiUri -Verbose:$false

    Write-Verbose "Determing the number of pages to process."
    $LastPageNumber = $null
    foreach ($relLink in ($ReleasesApiStart.Headers.Link -split ", ")) {
        $ApiPagesMatch = [regex]::Match($relLink, $ReleaseApiPagesRegex)

        $relName = $ApiPagesMatch.Groups | Where-Object -Property "Name" -eq "rel"
        $pageNum = $ApiPagesMatch.Groups | Where-Object -Property "Name" -eq "pageNumber"

        switch ($relName.Value) {
            "last" {
                $LastPageNumber = $pageNum.Value
                break
            }

            Default {
                $null
                break
            }
        }
    }
    Write-Verbose "Total number of pages: $($LastPageNumber)."

    $i = 1

    $ApiResults = @()
    while ($i -le $LastPageNumber) {
        Write-Verbose "Getting results from page $($i)/$($LastPageNumber)."
        $ApiCall = Invoke-RestMethod -Uri "$($ReleasesApiUri)?page=$($i)" -Method Get -Verbose:$false

        $ApiResults += $ApiCall
        $i++
    }

    $returnObj = @()

    foreach ($ApiResult in $ApiResults) {
        Write-Verbose "Processing Result - '$($ApiResult.name)'"
        $ReleaseAssetObjs = @()
        foreach ($obj in ($ApiResult.assets | Where-Object -Property "name" -Like "*-win-*")) {
            $releaseRegex = [regex]::Match($obj.name, $WindowsReleaseRegex)

            $archCapture = $releaseRegex.Groups | Where-Object -Property "Name" -eq "arch"
            $extCapture = $releaseRegex.Groups | Where-Object -Property "Name" -eq "extensions"

            $WinReleaseObj = [ReleaseAsset]::new()
            $WinReleaseObj.ReleaseName = $obj.name;
            $WinReleaseObj.ReleasePlatform = "Windows"
            $WinReleaseObj.ReleaseArch = $archCapture.Value
            $WinReleaseObj.ReleaseExt = $extCapture.Value
            $WinReleaseObj.ReleaseDownloadUri = $obj.browser_download_url

            $ReleaseAssetObjs += $WinReleaseObj
        }

        foreach ($obj in ($ApiResult.assets | Where-Object -Property "name" -Like "*-linux-*")) {
            $releaseRegex = [regex]::Match($obj.name, $LinuxReleaseRegex)

            $archCapture = $releaseRegex.Groups | Where-Object -Property "Name" -eq "arch"
            $extCapture = $releaseRegex.Groups | Where-Object -Property "Name" -eq "extensions"

            $LinuxReleaseObj = [ReleaseAsset]::new()
            $LinuxReleaseObj.ReleaseName = $obj.name;
            $LinuxReleaseObj.ReleasePlatform = "Linux"
            $LinuxReleaseObj.ReleaseArch = $archCapture.Value
            $LinuxReleaseObj.ReleaseExt = $extCapture.Value
            $LinuxReleaseObj.ReleaseDownloadUri = $obj.browser_download_url

            $ReleaseAssetObjs += $LinuxReleaseObj
        }

        foreach ($obj in ($ApiResult.assets | Where-Object -Property "name" -Like "*-osx-*")) {
            $releaseRegex = [regex]::Match($obj.name, $macOSReleaseRegex)

            $archCapture = $releaseRegex.Groups | Where-Object -Property "Name" -eq "arch"
            $extCapture = $releaseRegex.Groups | Where-Object -Property "Name" -eq "extensions"

            $macOSReleaseObj = [ReleaseAsset]::new()
            $macOSReleaseObj.ReleaseName = $obj.name;
            $macOSReleaseObj.ReleasePlatform = "macOS"
            $macOSReleaseObj.ReleaseArch = $archCapture.Value
            $macOSReleaseObj.ReleaseExt = $extCapture.Value
            $macOSReleaseObj.ReleaseDownloadUri = $obj.browser_download_url

            $ReleaseAssetObjs += $macOSReleaseObj
        }

        $ReleaseObj = [Release]::new()
        $ReleaseObj.Name = $ApiResult.name
        $ReleaseObj.VersionTag = $ApiResult.tag_name
        $ReleaseObj.ReleaseDate = [datetime]::Parse($ApiResult.published_at)
        $ReleaseObj.IsPreview = $ApiResult.prerelease
        $ReleaseObj.ReleasePageUri = $ApiResult.html_url

        $ReleaseObj.ReleaseAssets = $ReleaseAssetObjs

        $returnObj += $ReleaseObj
    }
}

end {
    return $returnObj
}