<#
.SYNOPSIS
Erases the `PackageReleaseNotes` node from the project's XML content.
.DESCRIPTION
Identifies and deletes the `PackageReleaseNotes` node from the provided XML document.
.PARAMETER XmlDocument
XML document representation of the .csproj file.
.EXAMPLE
RemovePackageReleaseNotes $xml
.NOTES
It's crucial to ensure that the XML document is a valid .csproj file and that modification permissions are available.
#>
function RemovePackageReleaseNotes([xml]$XmlDocument) {
    $Node = $XmlDocument.SelectSingleNode("//PackageReleaseNotes")
    if ($Node) {
        $Node.ParentNode.RemoveChild($node)
        Write-Host "PackageReleaseNotes node removed."
    } else {
        Write-Host "PackageReleaseNotes node not found. No changes made."
    }
}