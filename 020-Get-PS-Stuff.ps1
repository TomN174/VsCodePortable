<#PSScriptInfo
.VERSION 1.0.0.0
.GUID c2ea82bb-b205-417f-a6be-06b49d3812cc
.AUTHOR Thomas Naumann 
.COMPANYNAME Brose Fahrzeugteile SE & Co. Kommanditgesellschaft, Bamberg
.COPYRIGHT (c) by Thomas Naumann 
.TAGS Script Repository
.RELEASENOTES
2025.05.27_17.46.04 mofified by adminthn

#> 

<# 
.DESCRIPTION 
Script for Project AD Recovery
#> 

##end PSScriptInfo
#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param(
    $IsoRoot = 'D:\ISO-SH'
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
$PDC = (Get-ADDomain).PDCEmulator
$AdRecoverySourcePath = "\\$($PDC)\Service.local$\Scripts\AdRecovery"
$AdRecoveryDestinationPath = "$IsoRoot\AdRecovery"
[array]$shModules = 'ImportExcel','PSReadLine'
$shModulesPath = "$IsoRoot\PsModules"

if (Test-Path $shModulesPath) {
    Remove-Item -Path $shModulesPath -Recurse -Force
}
New-Item -ItemType Directory -Path $shModulesPath | Out-Null

foreach ($shModule in $shModules) {
    # Write-Progress -Id 861689 -Activity "Processing $($shModule)" -Status "Waiting for $($shModule)" -CurrentOperation "executing something on $($shModule)" -PercentComplete ([array]::indexof($shModules, $shModule) / $shModules.count * 100)
    Write-Host $shModule -ForegroundColor Cyan
    Find-Module $shModule | Save-Module -Path $shModulesPath
}

if (Test-Path $AdRecoveryDestinationPath) {
    Remove-Item -Path $AdRecoveryDestinationPath -Recurse -Force
}
New-Item -ItemType Directory -Path $AdRecoveryDestinationPath | Out-Null

Copy-Item -Path $AdRecoverySourcePath -Destination $AdRecoveryDestinationPath -Recurse -Force

#  $SnippetURl = "https://scm.brose.net/SRX/ad-test/MyProfile/-/blob/dev/Config/powershell.json?ref_type=heads"
#  $SnippetURl = "https://scm.brose.net/SRX/ad-test/MyProfile/-/blob/1aff2ca742dd5ac8d00b428e1105331f5bea5941/Config/powershell.json"
#  $SnippetURl = "https://scm.brose.net/SRX/ad-test/MyProfile/-/raw/dev/Config/powershell.json?ref_type=heads&inline=false"
                
#  Invoke-WebRequest -Uri $SnippetURl -OutFile "$DownloadPath\powershell.json" -c
$AdRecoverySourcePath


#Script ends here
$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
$br | Out-Null