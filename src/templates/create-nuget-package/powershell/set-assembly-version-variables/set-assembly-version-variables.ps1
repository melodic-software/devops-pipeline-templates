param(
    [string]$BuildId,
    [string]$BuildNumber,
    [string]$OriginalBuildNumber,
    [string]$SemVer,
    [string]$Major,
    [string]$Minor,
    [string]$Patch,
    [string]$PreReleaseLabel,
    [string]$ShortSha
)

# Default Minor and Patch if not set
$Minor = if ($Minor) { $Minor } else { "0" }
$Patch = if ($Patch) { $Patch } else { "0" }

$MajorMinorPatch = "$Major.$Minor.$Patch"

Write-Host "BuildId: $BuildId"
Write-Host "BuildNumber: $BuildNumber"

if (-not [string]::IsNullOrWhiteSpace($OriginalBuildNumber)) {
    Write-Host "OriginalBuildNumber: $OriginalBuildNumber"
}

Write-Host "SemVer: $SemVer"
Write-Host "Major: $Major"
Write-Host "Minor: $Minor"
Write-Host "Patch: $Patch"
Write-Host "MajorMinorPatch: $MajorMinorPatch"
Write-Host "PreReleaseLabel: $PreReleaseLabel"
Write-Host "ShortSha: $ShortSha"

# Define the regex pattern to match a build number format of 'yyyyMMdd.Revision'
# This pattern is used to match the standard Azure DevOps build number format.
$BuildNumberPattern = '^(\d{8})\.(\d+)$'

# Determine the effective build number to use.
# Check if either the OriginalBuildNumber or BuildNumber matches the expected Azure DevOps format.
# If a match is found, that value is used as the EffectiveBuildNumber.
$EffectiveBuildNumber = if ($OriginalBuildNumber -match $BuildNumberPattern) { 
    $OriginalBuildNumber 
}
elseif ($BuildNumber -match $BuildNumberPattern) { 
    $BuildNumber 
}
else { 
    $null 
}

if ($null -ne $EffectiveBuildNumber) {
    $DatePart = $EffectiveBuildNumber.Split('.')[0]
    $RevisionPart = $EffectiveBuildNumber.Split('.')[-1]

    $TwoDigitYear = $DatePart.Substring(2, 2)
    $DayOfYear = [DateTime]::ParseExact($DatePart, "yyyyMMdd", [Globalization.CultureInfo]::InvariantCulture).DayOfYear.ToString("D3")
    $SafeBuildId = "$TwoDigitYear$DayOfYear"
    $Revision = [int]$RevisionPart.PadLeft(2, '0')

    Write-Host "DatePart: $DatePart"
    Write-Host "TwoDigitYear: $TwoDigitYear"
    Write-Host "DayOfYear: $DayOfYear"
    Write-Host "Safe Build ID: $SafeBuildId"
    Write-Host "RevisionPart: $RevisionPart"
    Write-Host "Revision: $Revision"

    $AssemblyVersion = "$Major.0.0.0"
    Write-Host "AssemblyVersion: $AssemblyVersion"
    Write-Host "##vso[task.setvariable variable=AssemblyVersion]$AssemblyVersion"

    $FileVersion = "$Major.$Minor.$SafeBuildId.$Revision"
    Write-Host "FileVersion: $FileVersion"
    Write-Host "##vso[task.setvariable variable=FileVersion]$FileVersion"

    $InformationalVersion = "$MajorMinorPatch"
    if (-not [string]::IsNullOrEmpty($PreReleaseLabel)) {
        $InformationalVersion = "$InformationalVersion-$PreReleaseLabel"
    }
    $InformationalVersion = "$InformationalVersion+$ShortSha"
}
else {
    Write-Error "BuildNumber is not in the expected format."
    throw "Invalid BuildNumber format, cannot proceed."
}

Write-Host "InformationalVersion: $InformationalVersion"
Write-Host "##vso[task.setvariable variable=InformationalVersion]$InformationalVersion"

Write-Host "PackageVersion: $SemVer"
Write-Host "##vso[task.setvariable variable=PackageVersion]$SemVer"