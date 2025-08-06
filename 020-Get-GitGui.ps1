<#PSScriptInfo
.VERSION 1.0.0.0
.GUID 458ef87e-52ae-4258-8019-19af3afc341a
.AUTHOR Thomas Naumann 
.COMPANYNAME Brose Fahrzeugteile SE & Co. Kommanditgesellschaft, Bamberg
.COPYRIGHT (c) by Thomas Naumann 
.TAGS Script Repository
.RELEASENOTES
2025.05.28_15.34.45 mofified by adminthn

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
$DownloadPath = "$IsoRoot\Downloads"

# Ensure TLS 1.2 is used
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define architecture
$architecture = "64-bit"

# GitHub API endpoint for the latest release
$gitHubApi = "https://api.github.com/repos/git-for-windows/git/releases/latest"

# Get the latest release info
$response = Invoke-RestMethod -Uri $gitHubApi -ProxyCredential $ProxyCreds -Proxy $Proxy

# Find the correct asset
$asset = $response.assets | Where-Object { $_.name -like "*$architecture.exe" }

# Download the installer
# $destination = "$env:TEMP\$($asset.name)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$DownloadPath\$($asset.name)" -Proxy $Proxy -ProxyCredential $ProxyCreds

# Optionally run the installer
# Start-Process -FilePath $destination -Wait






#Script ends here
$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
$br | Out-Null