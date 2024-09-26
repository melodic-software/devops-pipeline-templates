<#
.SYNOPSIS
    Processes build information and sets assembly versioning variables for use in an Azure DevOps pipeline.
.DESCRIPTION
    This function takes various build-related parameters, processes them to generate assembly versioning information
    such as AssemblyVersion, FileVersion, and InformationalVersion, and sets these as Azure DevOps pipeline variables.
.PARAMETER BuildId
    The unique identifier for the build.
.PARAMETER BuildNumber
    The current build number.
.PARAMETER OriginalBuildNumber
    The original build number if it differs from the current BuildNumber.
.PARAMETER SemVer
    The semantic versioning string.
.PARAMETER Major
    The major version number.
.PARAMETER Minor
    The minor version number. Defaults to "0" if not provided.
.PARAMETER Patch
    The patch version number. Defaults to "0" if not provided.
.PARAMETER PreReleaseLabel
    The pre-release label, if any.
.PARAMETER ShortSha
    The short Git commit SHA.
.EXAMPLE
    Set-AssemblyVersionVariables -BuildId 123 -BuildNumber "20230801.1" -OriginalBuildNumber "20230801.1" `
        -SemVer "1.0.0" -Major "1" -Minor "0" -Patch "0" -PreReleaseLabel "beta" -ShortSha "abc123"
.NOTES
    This function expects the build number to follow the format 'yyyyMMdd.Revision'.
    It sets the following Azure DevOps pipeline variables: AssemblyVersion, FileVersion, InformationalVersion, PackageVersion.
#>
function Set-AssemblyVersionVariables {
    param(
        [string]$BuildId,
        [string]$BuildNumber,
        [string]$OriginalBuildNumber,
        [string]$SemVer,
        [string]$Major,
        [string]$Minor = "0",
        [string]$Patch = "0",
        [string]$PreReleaseLabel,
        [string]$ShortSha
    )

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
    $BuildNumberPattern = '^(\d{8})\.(\d+)$'

    # Determine the effective build number.
    $EffectiveBuildNumber = if ($OriginalBuildNumber -match $BuildNumberPattern) { 
        $OriginalBuildNumber 
    }
    elseif ($BuildNumber -match $BuildNumberPattern) { 
        $BuildNumber 
    }
    else { 
        $null 
    }

    # Best practice for assembly versions:
    # https://learn.microsoft.com/en-us/dotnet/standard/library-guidance/versioning

    $AssemblyVersion = "$Major.0.0.0"  # Only major version as per guidelines
    Write-Host "AssemblyVersion: $AssemblyVersion"
    Write-Host "##vso[task.setvariable variable=AssemblyVersion]$AssemblyVersion"

    if ($null -ne $EffectiveBuildNumber) {
        # If BuildNumber matches 'yyyyMMdd.Revision'
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

        # FileVersion includes Build (SafeBuildId) and Revision
        $FileVersion = "$Major.$Minor.$SafeBuildId.$Revision"
        Write-Host "FileVersion: $FileVersion"
        Write-Host "##vso[task.setvariable variable=FileVersion]$FileVersion"
    }
    else {
        # Fallback logic for invalid or unexpected build number formats
        Write-Warning "BuildNumber does not match expected format 'yyyyMMdd.Revision'. Applying fallback logic."

        # Fallback SafeBuildId: Current date and time for more uniqueness
        $CurrentDate = (Get-Date).ToString("yyDDD")  # Year + Day of the Year
        $CurrentTime = (Get-Date).ToString("HHmm")   # Hour and minute to ensure uniqueness within the same day
        $SafeBuildId = "$CurrentDate$CurrentTime"

        # Use a 3-digit hash of the ShortSha as the revision number for better uniqueness
        $ShortShaHash = [Math]::Abs(($ShortSha.GetHashCode() % 1000)).ToString("D3")

        # FileVersion includes Build (SafeBuildId + Time) and Revision (ShortShaHash)
        $FileVersion = "$Major.$Minor.$SafeBuildId.$ShortShaHash"
        Write-Host "FileVersion (Fallback): $FileVersion"
        Write-Host "##vso[task.setvariable variable=FileVersion]$FileVersion"
    }

    $InformationalVersion = "$MajorMinorPatch"
    if (-not [string]::IsNullOrEmpty($PreReleaseLabel)) {
        $InformationalVersion = "$InformationalVersion-$PreReleaseLabel"
    }
    $InformationalVersion = "$InformationalVersion+$ShortSha"
    Write-Host "InformationalVersion: $InformationalVersion"
    Write-Host "##vso[task.setvariable variable=InformationalVersion]$InformationalVersion"

    Write-Host "PackageVersion: $SemVer"
    Write-Host "##vso[task.setvariable variable=PackageVersion]$SemVer"
}