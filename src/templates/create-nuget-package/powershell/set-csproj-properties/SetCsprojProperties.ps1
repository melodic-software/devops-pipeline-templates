<#
.SYNOPSIS
    Updates properties in a .csproj file based on provided parameters.
.DESCRIPTION
    This function updates or adds properties in a specified .csproj file, such as repository information,
    signing options, and build configurations. It supports both .NET Core/Standard and .NET Framework projects.
.PARAMETER SourceDirectory
    The directory where the project file is located.
.PARAMETER ProjectName
    The name of the project file (.csproj) to update.
.PARAMETER RepositoryCommit
    The commit hash to be included in the .csproj file.
.PARAMETER RepositoryBranch
    The branch name to be included in the .csproj file.
.PARAMETER SignAssembly
    Specifies whether the assembly should be signed. Defaults to $true.
.PARAMETER IncludeSymbols
    Specifies whether to include symbols in the build. Defaults to $true.
.PARAMETER SymbolPackageFormat
    The format for the symbol package. Defaults to 'snupkg'.
.PARAMETER AssemblyOriginatorKeyFile
    The path to the key file used for signing the assembly.
.PARAMETER PathMap
    The path map used for source linking.
.PARAMETER IsDotNetFrameworkTarget
    Indicates if the target project is a .NET Framework project. Defaults to $false.
.PARAMETER OverwriteExisting
    Specifies whether to overwrite existing properties in the .csproj file. Defaults to $false.
.EXAMPLE
    Set-CsprojProperties -SourceDirectory "C:\Projects" -ProjectName "MyProject" -RepositoryCommit "abc123" `
        -RepositoryBranch "main" -SignAssembly $true -IncludeSymbols $true -AssemblyOriginatorKeyFile "key.snk" `
        -PathMap "src=C:\Source" -IsDotNetFrameworkTarget $false -OverwriteExisting $true
.NOTES
    This function assumes that the .csproj file uses XML namespaces and handles them accordingly.
#>
function Set-CsprojProperties {
    param(
        [string]$SourceDirectory,
        [string]$ProjectName,
        [string]$RepositoryCommit,
        [string]$RepositoryBranch,
        [bool]$SignAssembly = $true,
        [bool]$IncludeSymbols = $true,
        [string]$SymbolPackageFormat = 'snupkg',
        [string]$AssemblyOriginatorKeyFile,
        [string]$PathMap = $null,
        [bool]$IsDotNetFrameworkTarget = $false,
        [bool]$OverwriteExisting = $false
    )

    $Properties = @{
        "PublishRepositoryUrl"       = "true"
        "RepositoryCommit"           = $RepositoryCommit
        "RepositoryBranch"           = $RepositoryBranch
        "ContinuousIntegrationBuild" = "true"
        "Deterministic"              = "true"
        "DebugType"                  = "portable" # "none", "portable", "embedded", "full", or "pdbonly"
        "EmbedUntrackedSources"      = "true"
        "IncludeSymbols"             = $IncludeSymbols
        "SymbolPackageFormat"        = $SymbolPackageFormat
        "SourceLinkEnabled"          = "true"
    }

    if ($IsDotNetFrameworkTarget) {
        $Properties["DebugSymbols"] = "true"
    }

    if ($AssemblyOriginatorKeyFile) {
        $Properties["SignAssembly"] = $SignAssembly
        $Properties["AssemblyOriginatorKeyFile"] = $AssemblyOriginatorKeyFile
    }

    if (-not [string]::IsNullOrWhiteSpace($PathMap)) {
        $Properties["PathMap"] = $PathMap
    }

    Write-Host "Properties: $($Properties | Out-String)"

    function Set-ProjectProperty {
        param (
            [Parameter(Mandatory = $true)]
            [System.Xml.XmlDocument]$CsProjXml,
            [Parameter(Mandatory = $true)]
            [string]$PropertyName,
            [Parameter(Mandatory = $true)]
            [string]$PropertyValue,
            [System.Xml.XmlNamespaceManager]$NamespaceManager,
            [bool]$Overwrite
        )

        if ($null -eq $PropertyName) {
            Write-Host "Attempting to use a null key, which is not allowed. Skipping."
            return
        }
        
        if ($null -eq $PropertyValue) {
            Write-Host "Property value for key '$PropertyName' is null. Skipping property."
            return
        }
        
        $PropertyGroups = $CsProjXml.SelectNodes("//x:Project/x:PropertyGroup", $NamespaceManager)
        $PropertyExists = $false
        
        foreach ($PropertyGroup in $PropertyGroups) {
            $PropertyNode = $PropertyGroup.SelectSingleNode("x:$PropertyName", $NamespaceManager)
            if ($null -ne $PropertyNode) {
                $PropertyExists = $true
                $NoValue = [string]::IsNullOrEmpty($PropertyNode.InnerText)
                if ($Overwrite -or $NoValue) {
                    Write-Host "Updating property '$PropertyName' with value '$PropertyValue'."
                    $PropertyNode.InnerText = $PropertyValue
                }
                else {
                    Write-Host "Property '$PropertyName' already exists with value '$($PropertyNode.InnerText)'. Overwrite is set to false; skipping update."
                }
                break
            }
        }

        if (!$PropertyExists) {
            $PropertyGroupForAddition = $CsProjXml.SelectSingleNode("//x:Project/x:PropertyGroup[contains(@Condition, '`$(CI)') or contains(@Condition, '`$(TF_BUILD)')]", $NamespaceManager)
            if ($null -eq $PropertyGroupForAddition) {
                $PropertyGroupForAddition = $CsProjXml.SelectSingleNode("//x:Project/x:PropertyGroup[not(@Condition)][1]", $NamespaceManager)
            }

            if ($null -eq $PropertyGroupForAddition) {
                Write-Host "No appropriate PropertyGroup found for insertion; creating new PropertyGroup."
                $PropertyGroupForAddition = $CsProjXml.CreateElement("PropertyGroup", $CsProjXml.DocumentElement.NamespaceURI)
                $CsProjXml.DocumentElement.PrependChild($PropertyGroupForAddition)
            }

            Write-Host "Adding new property '$PropertyName' with value '$PropertyValue'."
            $NewProperty = $CsProjXml.CreateElement($PropertyName, $CsProjXml.DocumentElement.NamespaceURI)
            $NewProperty.InnerText = $PropertyValue
            $PropertyGroupForAddition.AppendChild($NewProperty) | Out-Null
        }

        return
    }

    try {
        Write-Host "Starting process to update .csproj file..."
        
        $CsProjFilePath = Get-ChildItem -Path $SourceDirectory -Recurse -Filter "$ProjectName.csproj" -ErrorAction Stop | Select-Object -First 1 -ExpandProperty FullName

        Write-Host "Found .csproj file for project '$ProjectName' at: $CsProjFilePath"

        $CsProjXml = [xml](Get-Content -Path $CsProjFilePath)
        
        $NamespaceManager = New-Object System.Xml.XmlNamespaceManager($CsProjXml.NameTable)
        $NamespaceManager.AddNamespace("x", $CsProjXml.DocumentElement.NamespaceURI)

        if ($CsProjXml.DocumentElement.NamespaceURI) {
            Write-Host "Namespace manager created for XML namespace: $($CsProjXml.DocumentElement.NamespaceURI)"
        }

        foreach ($PropertyName in $Properties.Keys) {
            Set-ProjectProperty -CsProjXml $CsProjXml -PropertyName $PropertyName -PropertyValue $Properties[$PropertyName] -NamespaceManager $NamespaceManager -Overwrite $OverwriteExisting
        }

        $CsProjXml.Save($CsProjFilePath) | Out-Null
        Write-Host "The .csproj file '$ProjectName' has been successfully updated."
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}
