<#
.SYNOPSIS
Locates .csproj files within the specified directory path.
.DESCRIPTION
Recursively searches for all .csproj files starting from the designated directory.
.PARAMETER Path
Directory path from which to begin the search for .csproj files.
.EXAMPLE
Get-ProjectFilePaths -Path "C:\path\to\projects"
.NOTES
Outputs an array containing the paths of all discovered .csproj files.
#>
function Get-ProjectFilePaths {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (-not (Test-Path $_ -PathType Container)) {
                    throw "Path '$_' does not exist or is not a directory."
                }
                return $true
            })]
        [string]$Path
    )

    Write-Host "Searching for .csproj files in: $Path"

    # Recursively retrieve all .csproj files within the specified directory
    $ProjectFiles = Get-ChildItem -Path $Path -File -Recurse | Where-Object { $_.Extension -eq ".csproj" }
    
    Write-Host "Discovered project files: $($ProjectFiles.FullName -join ', ')"
    Write-Output $ProjectFiles
}

# Note: When invoking this function in a script, it's a good practice to handle potential errors, e.g., 
# if no .csproj files are found or if the directory doesn't contain any files.