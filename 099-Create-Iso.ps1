<#PSScriptInfo
.VERSION 1.0.0.0
.GUID 8b46c78e-8566-4c94-a563-489540962d6a
.AUTHOR Thomas Naumann 
.COMPANYNAME Brose Fahrzeugteile SE & Co. Kommanditgesellschaft, Bamberg
.COPYRIGHT (c) by Thomas Naumann 
.TAGS Script Repository
.RELEASENOTES
2025.06.18_17.11.20 modified by adminthn

#> 

<# 
.DESCRIPTION 
Script for Project AdRecovery
#> 

##end PSScriptInfo
#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
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
$ServiceLocal = 'C:\Service.Local'
$br = [PSCustomObject] @{
    LogFile = "$ServiceLocal\Logs\AdRecovery\$($Log.LogDate)-$($Log.ScriptName)-Log.txt"
    OutFile = "$ServiceLocal\Logs\AdRecovery\$($Log.LogDate)-$($Log.ScriptName)-Outfile.txt"
    # XlsFile = "$ServiceLocal\Logs\AdRecovery\$($Log.LogDate)-$($Log.ScriptName).xlsx"
    # TransScript = "$ServiceLocal\Logs\AdRecovery\$($Log.LogDate)-$($Log.ScriptName)-Outfile.txt"
    
}
#endregion StandardObjects
    
#Script starts here
$OutputIsoName = "$(Get-Date -Format yyyy-MM-dd_HH-mm )_AD-Recovery"
$OutputIsoDestinationPath = "D:\ISO\$($OutputIsoName).iso"

New-ISOFile -source $IsoRoot -destinationIso $OutputIsoDestinationPath  -title $OutputIsoName -Verbose -force 

$IsoFinalDestinations =@(
    "\\DCES3231\d$\AD-ISO"
    "\\SYSS4000\Service.Local`$\Sources\AdRecovery"
    "\\SYSS4001\Service.Local`$\Sources\AdRecovery"
)

foreach ($IsoFinalDestination in $IsoFinalDestinations) {
# Write-Progress -Id 239746 -Activity "Processing $($IsoFinalDestination)" -Status "Waiting for $($IsoFinalDestination)" -CurrentOperation "executing something on $($IsoFinalDestination)" -PercentComplete ([array]::indexof($IsoFinalDestinations, $IsoFinalDestination) / $IsoFinalDestinations.count * 100)
Write-Host "copy Iso $OutputIsoName to  $IsoFinalDestination"  -ForegroundColor Cyan
Copy-Item -Path $OutputIsoDestinationPath -Destination $IsoFinalDestination -Force

}


 


# Stop-Transcript
#Script ends here
$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
