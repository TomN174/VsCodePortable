<#PSScriptInfo
.VERSION 1.0.0.0
.GUID adb3ecbd-fd0a-4157-9f05-fc67b42da769
.AUTHOR Thomas Naumann 
.COMPANYNAME Brose Fahrzeugteile SE & Co. Kommanditgesellschaft, Bamberg
.COPYRIGHT (c) by Thomas Naumann 
.TAGS Script Repository
.RELEASENOTES
2025.05.27_16.54.50 mofified by adminthn

#> 

<# 
.DESCRIPTION 
Script for Project PsDev
#> 

##end PSScriptInfo
#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
    $IsoRoot = 'D:\ISO-SH',
    $Proxy = 'http://nat-proxy-eu.brose.net:65432',
    [Parameter()]
    [pscredential]
    $ProxyCreds = $ohnauma
)
#endregion Paramsection

#region Project Path V 3.0
[System.Collections.ArrayList]$PathArrayList = $PSScriptRoot.Split('\')
while (!((Test-Path "$($PathArrayList -join '\')\Readme.md") -and (Test-Path "$($PathArrayList -join '\')\Modules") ) -and ($PathArrayList.Count -gt 0)) {
    $PathArrayList.RemoveAt($PathArrayList.Count - 1)
} 
$ProjectPath = $PathArrayList -join '\'
#endregion Project Path

#region load project module V3.0
if ($ProjectPath) {
    $Modules = Get-ChildItem $ProjectPath\Modules -Directory
    Import-Module $Modules.FullName -Force #-Verbose 
}
#endregion load project module

#region StandardObjects V 3.0
$Log = Get-LogObj
# $br = [PSCustomObject] @{
#     LogFile = "$($Log.ScriptPath)\$($Log.ScriptName)-$($Log.LogDate)-Log.txt"
#     OutFile = "$($Log.ScriptPath)\$($Log.ScriptName)-$($Log.LogDate).txt"
# }
#endregion StandardObjects
    
#Script starts here

# $extractPath = "IsoRoot\NotepadPlusPlus$version"
$DownloadPath = "$IsoRoot\Downloads"
$extractPath = "$IsoRoot\NotepadPlusPlus"


if (-Not (Test-Path -Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath | Out-Null
}


if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}

# GitHub API URL for latest release
$apiUrl = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"

# Set headers to avoid GitHub API issues
$headers = @{ "User-Agent" = "PowerShell" }

# Get latest release info
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -ProxyCredential $ProxyCreds -Proxy $Proxy
$version = $response.tag_name.TrimStart("v")
$zipPath = "$DownloadPath\npp.$version.portable.x64.zip"

# Find the 64-bit portable ZIP asset
$asset = $response.assets | Where-Object { $_.name -like "*portable.x64.zip" }

if ($null -ne $asset) {
    $downloadUrl = $asset.browser_download_url
    
    
    # Download the ZIP
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -ProxyCredential $ProxyCreds -Proxy $Proxy
    
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


#Script ends here
$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
$br | Out-Null