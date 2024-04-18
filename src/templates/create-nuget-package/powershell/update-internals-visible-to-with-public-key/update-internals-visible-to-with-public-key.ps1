param(
    [string] $SourceDirectory,
    [string] $PublicKey
)

Write-Host "Scanning for .csproj files in directory: $SourceDirectory"
Get-ChildItem -Path $SourceDirectory -Filter *.csproj -Recurse | ForEach-Object {
    $CsProjPath = $_.FullName
    [xml]$CsProjXml = Get-Content $CsProjPath
    
    $Updated = $false
    $ItemGroups = $CsProjXml.Project.ItemGroup
    foreach ($ItemGroup in $ItemGroups) {
        if ($ItemGroup.InternalsVisibleTo) {
            foreach ($InternalsVisibleTo in $ItemGroup.InternalsVisibleTo) {
                if (-not $InternalsVisibleTo.Include.Contains("PublicKey=")) {
                    # Check if the include attribute ends with a comma before appending public key.
                    $Suffix = $InternalsVisibleTo.Include.EndsWith(",") ? "" : ","
                    $InternalsVisibleTo.Include += "${Suffix} PublicKey=$PublicKey"
                    $Updated = $true
                    Write-Host "Appending PublicKey to $($InternalsVisibleTo.Include) in file: $CsProjPath"
                }
            }
        }
    }
    
    if ($Updated) {
        $CsProjXml.Save($CsProjPath)
        Write-Host "Successfully updated: $CsProjPath"
    }
}