<#
.SYNOPSIS
    Inserts a new `PackageReleaseNotes` node into the project's XML content if it doesn't already exist.
.DESCRIPTION
    For project XMLs lacking a `PackageReleaseNotes` node, this function creates and adds one with the specified notes.
.PARAMETER XmlDocument
    XML document representation of the .csproj file.
.PARAMETER Notes
    Release note content intended for addition to the project.
.EXAMPLE
    Add-ReleaseNotesToCsproj -XmlDocument $xml -Notes "Several enhancements and bug fixes"
.NOTES
    Ensure the XML document accurately represents a .csproj file, and that necessary permissions to alter it are granted.
#>
function Add-ReleaseNotesToCsproj {
    param (
        [xml]$XmlDocument,
        [string]$Notes
    )

    $NewNode = $XmlDocument.CreateElement("PackageReleaseNotes")
    $NewNode.InnerText = $Notes

    $TargetPropertyGroup = $XmlDocument.SelectSingleNode("//PropertyGroup[TargetFramework]")
    if ($TargetPropertyGroup) {
        $TargetPropertyGroup.AppendChild($NewNode)
        Write-Host "Added new PackageReleaseNotes node to the targeted PropertyGroup."
    }
    else {
        Write-Warning "No PropertyGroup with TargetFramework found. No changes made."
    }
}
