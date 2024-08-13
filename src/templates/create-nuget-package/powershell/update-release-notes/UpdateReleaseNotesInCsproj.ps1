<#
.SYNOPSIS
    Modifies or appends the `PackageReleaseNotes` node in the project's XML based on its presence.
.DESCRIPTION
    In scenarios where the project XML possesses a `PackageReleaseNotes` node, it undergoes an update.
    Conversely, if absent, a new node with the provided notes is created and inserted.
.PARAMETER XmlDocument
    XML document representation of the .csproj file.
.PARAMETER Notes
    Release note content designated for setting in the project.
.EXAMPLE
    Update-ReleaseNotesInCsproj -XmlDocument $xml -Notes "Incorporated several bug fixes and feature enhancements"
.NOTES
    This function relies on the `Add-ReleaseNotesToCsproj` function to seamlessly perform its tasks when required.
#>
function Update-ReleaseNotesInCsproj {
    param (
        [xml]$XmlDocument,
        [string]$Notes
    )

    $Node = $XmlDocument.SelectSingleNode("//PackageReleaseNotes")
    if ($Node) {
        $Node.InnerText = $Notes
        Write-Host "Updated PackageReleaseNotes node."
    }
    else {
        Add-ReleaseNotesToCsproj -XmlDocument $XmlDocument -Notes $Notes
    }
}
