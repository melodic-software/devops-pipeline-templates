<#
.SYNOPSIS
Downloads and loads the 'powershell-yaml' module from a given URL with retry logic.
.DESCRIPTION
This function attempts to download and load the 'powershell-yaml' module.
If any error occurs during the download or extraction, it retries for a specified number of attempts with a delay between each try.
.PARAMETER YamlModuleUrl
The URL from which the 'powershell-yaml' module will be downloaded.
.PARAMETER RetryCount
Number of times the function should retry downloading and loading the module in case of failure.
.PARAMETER RetryInterval
Time (in seconds) to wait between each retry attempt.
.EXAMPLE
DownloadYamlModule -YamlModuleUrl 'https://www.powershellgallery.com/api/v2/package/powershell-yaml/0.4.7' -RetryCount 3 -RetryInterval 10
.NOTES
Implements retry logic to handle transient issues during download.
#>
function DownloadYamlModule {
    param(
        [Parameter(Mandatory=$true)]
        [string] $YamlModuleUrl,
        [int] $RetryCount = 3,
        [int] $RetryInterval = 10,
        [Parameter(Mandatory=$true)]
        [string] $WorkingDirectory
    )

    # Validate URL format
    if (-not [Uri]::IsWellFormedUriString($YamlModuleUrl, [UriKind]::Absolute)) {
        throw "The provided URL is not a valid absolute URI: $YamlModuleUrl"
    }

    $ModuleName = "powershell-yaml"

    for ($Index = 1; $Index -le $RetryCount; $Index++) {
        try {
            $OutputPath = Join-Path -Path $WorkingDirectory -ChildPath "$ModuleName.zip"

            # Download the .nupkg file
            Invoke-WebRequest -Uri $YamlModuleUrl -OutFile $OutputPath
            Write-Host "Module package downloaded successfully on attempt $Index."

            # Extract the .nupkg (zip) file
            $ExtractDirectory = Join-Path -Path $WorkingDirectory -ChildPath $ModuleName
            Expand-Archive -Path $OutputPath -DestinationPath $ExtractDirectory -Force

            # Find and load the .psd1 module file
            $ModulePath = Get-ChildItem -Path $ExtractDirectory -Filter "*.psd1" -Recurse | Select-Object -First 1 -ExpandProperty FullName
            Import-Module -Name $ModulePath -Force

            Write-Host "YAML Parser module has been loaded successfully on attempt $Index."
            break  # Exit the loop since the module was successfully downloaded and loaded.
        } catch {
            Write-Warning ("Attempt {0}: An error occurred while downloading and extracting the 'powershell-yaml' module: {1}" -f $Index, $_.Exception.Message)
            if ($Index -lt $RetryCount) {
                Write-Host "Waiting $RetryInterval seconds before retrying..."
                Start-Sleep -Seconds $RetryInterval
            } else {
                throw "All retry attempts failed."
            }
        }
    }
}