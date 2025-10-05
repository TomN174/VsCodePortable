<#
.SYNOPSIS
Downloads the latest 64-bit Git for Windows installer from GitHub.

.DESCRIPTION
This script retrieves the latest release information for Git for Windows from the official GitHub repository, locates the 64-bit installer asset, and downloads it to a specified directory. The script ensures the download path exists and uses PowerShell's web cmdlets to interact with the GitHub API and download the installer.

.PARAMETER IsoRoot
Specifies the root directory where the installer will be downloaded. Defaults to 'D:\ISO-VsCode'.

.NOTES
- Requires internet access.
- Optionally, the installer can be executed after download by uncommenting the relevant line.
- Ensure TLS 1.2 is enabled if required by your environment.

.EXAMPLE
.\020-Get-GitGui.ps1 -IsoRoot 'D:\CustomPath'
Downloads the latest 64-bit Git for Windows installer to 'D:\CustomPath\Downloads'.
#>

#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
    $IsoRoot = 'D:\ISO-VsCode'
)
#endregion Paramsection

$DownloadPath = "$IsoRoot\Downloads"

# Ensure TLS 1.2 is used
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define architecture
$architecture = "64-bit"

# GitHub API endpoint for the latest release
$gitHubApi = "https://api.github.com/repos/git-for-windows/git/releases/latest"

# Get the latest release info
$response = Invoke-RestMethod -Uri $gitHubApi 

# Find the correct asset
$asset = $response.assets | Where-Object { $_.name -like "*$architecture.exe" }

# Download the installer
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$DownloadPath\$($asset.name)" 

# Optionally run the installer
# Start-Process -FilePath $destination -Wait
