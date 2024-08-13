<#
.SYNOPSIS
    Erases the `PackageReleaseNotes` node from the project's XML content.
.DESCRIPTION
    Identifies and deletes the `PackageReleaseNotes` node from the provided XML document.
.PARAMETER XmlDocument
    XML document representation of the .csproj file.
.EXAMPLE
    Remove-ReleaseNotesFromCsproj -XmlDocument $xml
.NOTES
    It's crucial to ensure that the XML document is a valid .csproj file and that modification permissions are available.
#>
function Remove-ReleaseNotesFromCsproj {
    param (
        [xml]$XmlDocument
    )

    $Node = $XmlDocument.SelectSingleNode("//PackageReleaseNotes")
    if ($Node) {
        $Node.ParentNode.RemoveChild($Node)
        Write-Host "PackageReleaseNotes node removed."
    }
    else {
        Write-Host "PackageReleaseNotes node not found. No changes made."
    }
}
