<#
.SYNOPSIS
Normalizes the path separators based on the operating system.
.DESCRIPTION
This function takes a path string and replaces its separators with the appropriate character based on the operating system.
For Windows, it ensures the path uses backslashes (`\`), and for Unix-like systems, it ensures the path uses forward slashes (`/`).
.PARAMETER Path
The path string to be normalized.
.EXAMPLE
$NormalizedPath = NormalizePathSeparator -Path "C:/Windows/System32"
Output:
C:\Windows\System32
.NOTES
Useful when working with paths that might come from different systems and you want to ensure they're correctly formatted for the current operating system.
#>
function NormalizePathSeparator {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        $DirectorySeparator = [IO.Path]::DirectorySeparatorChar # This gets the OS-specific separator, but can be specified for testing purposes.
    )

    # Correct the directory separators in the path
    if ($DirectorySeparator -eq "\") {
        # If we are on Windows, replace forward slashes with backslashes
        $CorrectedPath = $Path -replace '/', '\'
    } else {
        # If we are on a Unix-like system, replace backslashes with forward slashes
        $CorrectedPath = $Path -replace '\\', '/'
    }

    return $CorrectedPath
}