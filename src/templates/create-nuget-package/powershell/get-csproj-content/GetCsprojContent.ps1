<#
.SYNOPSIS
    Loads and displays the contents of a .csproj file for a given project.
.DESCRIPTION
    This function searches for the specified .csproj file within the provided source directory,
    loads the XML content of the .csproj file, and outputs the formatted content to the console.
.PARAMETER SourceDirectory
    The directory where the function should start searching for the .csproj file.
.PARAMETER ProjectName
    The name of the project for which the .csproj file needs to be found.
.EXAMPLE
    Get-CsprojContent -SourceDirectory "C:\Projects" -ProjectName "MyProject"
.NOTES
    Ensure that the SourceDirectory path is correct and accessible.
    This function is intended for use with .NET projects that utilize .csproj files.
#>
function Get-CsprojContent {
    param(
        [string]$SourceDirectory,
        [string]$ProjectName
    )

    try {
        # Find the .csproj file
        $CsProjPath = Get-ChildItem -Path $SourceDirectory -Recurse -Filter "$ProjectName.csproj" | Select-Object -First 1 -ExpandProperty FullName
        if (-not $CsProjPath) {
            throw "Could not find .csproj file for project $ProjectName."
        }
        Write-Host "Found .csproj file at: $CsProjPath"

        # Load the csproj XML
        [xml]$CsProjXml = Get-Content -Path $CsProjPath

        # Output the entire .csproj content with formatting
        $StringWriter = New-Object System.IO.StringWriter
        $XmlTextWriter = New-Object System.Xml.XmlTextWriter $StringWriter
        $XmlTextWriter.Formatting = [System.Xml.Formatting]::Indented
        $CsProjXml.Save($XmlTextWriter)
        Write-Host "Current .csproj content:"
        Write-Host $StringWriter.ToString()

    }
    catch {
        Write-Error "An error occurred: $_"
        exit 1
    }
    finally {
        # Clean up
        if ($XmlTextWriter) {
            $XmlTextWriter.Dispose()
        }
        if ($StringWriter) {
            $StringWriter.Dispose()
        }
    }
}
