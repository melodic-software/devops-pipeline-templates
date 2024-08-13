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
    # Ensure deterministic builds for full .NET Framework projects
    $Properties["DebugSymbols"] = "true" # This is less common in .NET standard projects
}

# Add 'AssemblyOriginatorKeyFile' only if it has a value.
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
    
    # Find all PropertyGroups
    $PropertyGroups = $CsProjXml.SelectNodes("//x:Project/x:PropertyGroup", $NamespaceManager)
    $PropertyExists = $false
    
    # Check all PropertyGroups to see if the property already exists
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
            break # Stop the loop if we found the property, whether we updated it or not
        }
    }

    if (!$PropertyExists) {
        # If the property does not exist, add it to the appropriate PropertyGroup
        # Prefer PropertyGroups with conditions for CI or TF_BUILD, otherwise take the first one without a condition
        $PropertyGroupForAddition = $CsProjXml.SelectSingleNode("//x:Project/x:PropertyGroup[contains(@Condition, '`$(CI)') or contains(@Condition, '`$(TF_BUILD)')]", $NamespaceManager)
        if ($null -eq $PropertyGroupForAddition) {
            # If no conditioned PropertyGroup is found, take the first one without a condition
            $PropertyGroupForAddition = $CsProjXml.SelectSingleNode("//x:Project/x:PropertyGroup[not(@Condition)][1]", $NamespaceManager)
        }

        if ($null -eq $PropertyGroupForAddition) {
            # If no PropertyGroup is found, create a new one without a condition
            Write-Host "No appropriate PropertyGroup found for insertion; creating new PropertyGroup."
            $PropertyGroupForAddition = $CsProjXml.CreateElement("PropertyGroup", $CsProjXml.DocumentElement.NamespaceURI)
            $CsProjXml.DocumentElement.PrependChild($PropertyGroupForAddition)
        }

        Write-Host "Adding new property '$PropertyName' with value '$PropertyValue'."
        $NewProperty = $CsProjXml.CreateElement($PropertyName, $CsProjXml.DocumentElement.NamespaceURI)
        $NewProperty.InnerText = $PropertyValue
        $PropertyGroupForAddition.AppendChild($NewProperty) | Out-Null
    }

    # This explicit return ensures we do not produce any unintended output
    return
}

try {
    Write-Host "Starting process to update .csproj file..."
    
    # Find the .csproj file
    $CsProjFilePath = Get-ChildItem -Path $SourceDirectory -Recurse -Filter "$ProjectName.csproj" -ErrorAction Stop | Select-Object -First 1 -ExpandProperty FullName

    Write-Host "Found .csproj file for project '$ProjectName' at: $CsProjFilePath"

    $CsProjXml = [xml](Get-Content -Path $CsProjFilePath)
    
    # Create a namespace manager for XPath since .csproj uses namespaces
    $NamespaceManager = New-Object System.Xml.XmlNamespaceManager($CsProjXml.NameTable)
    $NamespaceManager.AddNamespace("x", $CsProjXml.DocumentElement.NamespaceURI)

    if ($CsProjXml.DocumentElement.NamespaceURI) {
        Write-Host "Namespace manager created for XML namespace: $($CsProjXml.DocumentElement.NamespaceURI)"
    }

    # Loop through all properties and set or add them in the project file
    foreach ($PropertyName in $Properties.Keys) {
        Set-ProjectProperty -CsProjXml $CsProjXml -PropertyName $PropertyName -PropertyValue $Properties[$PropertyName] -NamespaceManager $NamespaceManager -Overwrite $OverwriteExisting
    }

    # Save the changes back to the .csproj file
    $CsProjXml.Save($CsProjFilePath) | Out-Null
    Write-Host "The .csproj file '$ProjectName' has been successfully updated."
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}