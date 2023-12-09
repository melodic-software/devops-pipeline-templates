<#
.SYNOPSIS
Determines whether a given project is a .NET Standard project based on its content.
.DESCRIPTION
Evaluates the provided project file content to determine if it represents a .NET Standard project.
The function first tries XML parsing for accuracy and falls back to regex matching if the content is not valid XML.
The identification is based on searching for 'netstandard' within the `<TargetFramework>` or `<TargetFrameworks>` tags.
.PARAMETER ProjectContent
The content of the project file to be evaluated.
.EXAMPLE
$Project = Get-Content -Path "C:\path\to\project.csproj"
$IsDotNetStandard = IsDotNetStandardProject -ProjectContent $Project
if ($IsDotNetStandard) { Write-Host "This is a .NET Standard project" }
#>
function IsDotNetStandardProject {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$ProjectContent
    )

    # Quick validation if the content even looks like a .csproj file
    if (-not ($ProjectContent -like "*<Project*")) {
        Write-Host "Content doesn't appear to be a .csproj file."
        return $false
    }

    $Xml = $null
    try {
        $Xml = New-Object System.Xml.XmlDocument
        $Xml.LoadXml($ProjectContent)

        # Remove the namespace if it exists to simplify the XPath query
        $XmlDocument.InnerXml = $XmlDocument.InnerXml -replace 'xmlns="[^"]+"', ''

        $FrameworkNodes = $Xml.SelectNodes("//*[local-name()='TargetFramework' or local-name()='TargetFrameworks']")
        $NetStandardCheck = $FrameworkNodes | Where-Object { $_ -like "*netstandard*" }

        return ($null -ne $NetStandardCheck -and $NetStandardCheck.Count -gt 0)
    } catch {
        Write-Host "Failed to parse content as XML. Falling back to regex matching."
        return $ProjectContent -match '<TargetFramework.*>netstandard.*<\/TargetFramework>|<TargetFrameworks.*>netstandard.*<\/TargetFrameworks>'
    }
}