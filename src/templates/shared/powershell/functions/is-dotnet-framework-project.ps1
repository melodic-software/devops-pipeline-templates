<#
.SYNOPSIS
Determines whether a given project file is a .NET Framework project.
.DESCRIPTION
This script evaluates a project file's contents to determine if it represents a .NET Framework project. 
The identification is based on the absence of the SDK attribute in the <Project> tag and the presence of the <TargetFrameworkVersion> tag.
.PARAMETER ProjectFilePath
The path to the project file that needs to be evaluated.
.EXAMPLE
$IsDotNetFrameworkProject = IsDotNetFrameworkProject -ProjectFilePath "C:\path\to\project.csproj"
if ($IsDotNetFrameworkProject) { Write-Host "This is a .NET Framework project." }
else { Write-Host "This is not a .NET Framework project." }
#>
function IsDotNetFrameworkProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectContent
    )

    # Quick validation to see if the content looks like a .csproj file
    if (-not ($ProjectContent -like "*<Project*")) {
        Write-Host "Content does not appear to be a .csproj file." -ForegroundColor Yellow
        return $false
    }

    try {
        $XmlDocument = New-Object System.Xml.XmlDocument
        $XmlDocument.LoadXml($ProjectContent)

        $ProjectNode = $XmlDocument.SelectSingleNode("/Project")
        if ($ProjectNode -and -not $ProjectNode.HasAttribute('Sdk')) {
            $TargetFrameworkNode = $ProjectNode.SelectSingleNode("PropertyGroup/TargetFrameworkVersion")
            if ($TargetFrameworkNode -and $TargetFrameworkNode.'#text' -like "v*") {
                Write-Host "This is a .NET Framework project." -ForegroundColor Green
                return $true
            } else {
                Write-Host "No TargetFrameworkVersion tag found, this is not a .NET Framework project." -ForegroundColor Yellow
                return $false
            }
        } else {
            Write-Host "Project uses the SDK format, it is not a .NET Framework project." -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "Failed to parse project content as XML, falling back to regex matching." -ForegroundColor Red

        # Check if it's not an SDK-style project using regex
        $IsNotSdkStyle = -not ($ProjectContent -match '<Project\s+Sdk="Microsoft\.NET\.Sdk"')
        if ($IsNotSdkStyle -and ($ProjectContent -match '<TargetFrameworkVersion>v[0-9]+(\.[0-9]+)+</TargetFrameworkVersion>')) {
            Write-Host "Based on regex analysis, this is a .NET Framework project." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Based on regex analysis, this is not a .NET Framework project." -ForegroundColor Yellow
            return $false
        }
    }
}

# Example usage:
# $Result = IsDotNetFrameworkProject -ProjectFilePath "path\to\your\project.csproj"
# if ($Result) { /* Do something if it is a .NET Framework project */ }
# else { /* Do something else if it is not a .NET Framework project */ }