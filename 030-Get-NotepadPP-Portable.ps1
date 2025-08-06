<#
.SYNOPSIS
Downloads and extracts the latest Notepad++ Portable (64-bit) release from GitHub.

.DESCRIPTION
This script automates the process of downloading the latest portable 64-bit version of Notepad++ from its official GitHub releases. It uses the GitHub API to determine the latest release, locates the appropriate ZIP asset, downloads it, and extracts its contents to a specified directory. The script also cleans up any previous installation in the target directory before extraction and saves the version information in a text file.

.PARAMETER IsoRoot
Specifies the root directory where Notepad++ Portable and its downloads will be stored. Defaults to 'C:\ISO-VsCode'.

.NOTES
- Requires internet access to fetch releases from GitHub.
- Overwrites any existing Notepad++ Portable installation in the target directory.
- Tested with PowerShell 5.1 and later.

.EXAMPLE
.\030-Get-NotepadPP-Portable.ps1 -IsoRoot 'D:\PortableApps'
Downloads and extracts the latest Notepad++ Portable to 'D:\PortableApps\NotepadPlusPlus'.

#>

#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
    $IsoRoot = 'C:\ISO-VsCode'
)
#endregion Paramsection


# $extractPath = "IsoRoot\NotepadPlusPlus$version"
$DownloadPath = "$IsoRoot\Downloads"
$extractPath = "$IsoRoot\NotepadPlusPlus"

# Ensure the download directory exists
if (-Not (Test-Path -Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath | Out-Null
}

# Cleanup previous installation
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}

# GitHub API URL for latest release
$apiUrl = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"

# Set headers to avoid GitHub API issues
$headers = @{ "User-Agent" = "PowerShell" }

# Get latest release info
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers 
$version = $response.tag_name.TrimStart("v")
$zipPath = "$DownloadPath\npp.$version.portable.x64.zip"

# Find the 64-bit portable ZIP asset
$asset = $response.assets | Where-Object { $_.name -like "*portable.x64.zip" }

if ($null -ne $asset) {
    $downloadUrl = $asset.browser_download_url
    
    
    # Download the ZIP
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath 
    
    # Create extraction directory
    if (-Not (Test-Path -Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath | Out-Null
    }
    
    # Extract ZIP
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractPath)
    Set-Content -Path "$extractPath\_Version.txt" -Value $version

    Write-Host "Notepad++ Portable $version downloaded and extracted to: $extractPath"
}
else {
    Write-Host "Could not find the portable x64 ZIP in the latest release."
}


