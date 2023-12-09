<#
.SYNOPSIS
Resolves the full path to .csproj file(s) based on the provided path pattern.
.DESCRIPTION
The Resolve-ProjectPath function processes a potentially ambiguous path input, which can include wildcards, incomplete paths, or specific file names.
It resolves these to the precise path of a .csproj file or a common base root directory.
The function handles various path scenarios, accommodating the intricacies of file path patterns within a file system.
It ensures consistency and accuracy in locating the .csproj files for build operations or other project setup tasks.
.PARAMETER Path
The path pattern input that requires resolution. This parameter can receive several types of input:
1. A specific file name (e.g., 'myproject.csproj').
2. A wildcard pattern that represents multiple possibilities (e.g., '*project.csproj').
3. A directory path, potentially including wildcards, indicating the .csproj file is within this directory or its subdirectories.
.EXAMPLE
Resolve-ProjectPath -Path "demo-package/**/Enterprise.Demo.csproj"
This command returns the full path to the 'Enterprise.Demo.csproj' file if it exists within the 'demo-package' directory structure.
It is useful when the .csproj file is located within a nested directory structure.
.EXAMPLE
Resolve-ProjectPath -Path "demo-package/*.csproj"
This command is used in scenarios where the exact .csproj file name is unknown, or there might be multiple .csproj files.
It returns the base directory containing the .csproj files, assisting in operations where any .csproj file is to be selected or processed.
.EXAMPLE
Resolve-ProjectPath -Path "demo-package/"
This command is used when a directory is specified without a file name or wildcard.
The function returns the input path normalized.
It's helpful in scenarios where subsequent operations are intended on the directory rather than a specific .csproj file.
.EXAMPLE
Resolve-ProjectPath -Path "Enterprise.Demo.csproj"
This command is ideal for scenarios where the build script is executed in the project's root directory, where the .csproj file resides.
If a specific .csproj file name is provided, the function returns its full path if it's in the script's root directory.
.NOTES
- The function throws an exception if it cannot find the specified .csproj file within the provided path context.
This ensures that build processes or other setup operations do not proceed with an incorrect path reference.
- The returned path uses forward slashes ('/') for compatibility across different operating systems and environments.
#>
function Resolve-ProjectPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    try {
        # Normalize the path separators for cross-platform compatibility.
        $NormalizedPath = $Path.Replace('\', '/')

        # Initialize the result; this will be the output path.
        $Result = $null

        # Check if the path specifically ends with a .csproj file name (excluding the "*.csproj" pattern).
        $IsSpecificCsproj = $NormalizedPath -match '.*\/([^\/]+\.csproj)$' -and -not $NormalizedPath.EndsWith('*.csproj')

        if ($IsSpecificCsproj) {
            # Extract the specific .csproj file name.
            $CsprojName = $Matches[1]

            # Find the base directory for the search. It's the part of the path before the project file name.
            $SearchBase = $NormalizedPath.Substring(0, $NormalizedPath.Length - $CsprojName.Length)

            # Remove any wildcards from the base path to prevent erroneous searches.
            $SearchBase = $SearchBase.Replace("**", "").Replace("*", "")

            # Trim any trailing slashes from the base path.
            $SearchBase = $SearchBase.TrimEnd('/')

            # Perform a recursive search for the .csproj file within the base directory.
            $FoundCsproj = Get-ChildItem -Path $SearchBase -Filter $CsprojName -Recurse -File | Select-Object -First 1

            if ($FoundCsproj) {
                # Return the full path of the found .csproj file, normalized to use forward slashes.
                $Result = $FoundCsproj.FullName.Replace('\', '/')
            } else {
                throw "No .csproj file found matching the name '$CsprojName' within '$SearchBase'."
            }
        } else {
            # For paths with wildcards or without a specific .csproj file, resolve the directory.
            
            # If there's a '**', we resolve up to the directory before it.
            if ($NormalizedPath.Contains('**')) {
                $Result = $NormalizedPath.Substring(0, $NormalizedPath.IndexOf('**')).TrimEnd('/')
            } elseif ($NormalizedPath.EndsWith('*.csproj')) {
                # If the path seeks any .csproj file (but not a specific one), resolve to the directory.
                $Result = Split-Path $NormalizedPath -Parent
            } else {
                # In other cases (like direct directory references), return the normalized path.
                $Result = $NormalizedPath
            }
        }

        return $Result
    } catch {
        throw $_
    }
}