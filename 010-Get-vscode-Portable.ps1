<#PSScriptInfo
.VERSION 1.0.0.0
.GUID fde430bd-0401-4367-aae4-29095ec8afe8
.AUTHOR Thomas Naumann 
.COMPANYNAME Brose Fahrzeugteile SE & Co. Kommanditgesellschaft, Bamberg
.COPYRIGHT (c) by Thomas Naumann 
.TAGS Script Repository
.RELEASENOTES
2025.05.27_17.02.45 mofified by adminthn

#> 

<# 
.DESCRIPTION 
Script for Project PsDev
#> 

##end PSScriptInfo
#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
    $IsoRoot = 'C:\ISO-VsCode'
)
#endregion Paramsection

# #region Project Path V 3.0
# [System.Collections.ArrayList]$PathArrayList = $PSScriptRoot.Split('\')
# while (!((Test-Path "$($PathArrayList -join '\')\Readme.md") -and (Test-Path "$($PathArrayList -join '\')\Modules") ) -and ($PathArrayList.Count -gt 0)) {
#     $PathArrayList.RemoveAt($PathArrayList.Count - 1)
# } 
# $ProjectPath = $PathArrayList -join '\'
# #endregion Project Path

# #region load project module V3.0
# if ($ProjectPath) {
#     $Modules = Get-ChildItem $ProjectPath\Modules -Directory
#     Import-Module $Modules.FullName -Force #-Verbose 
# }
# #endregion load project module

# #region StandardObjects V 3.0
# $Log = Get-LogObj
# # $br = [PSCustomObject] @{
# #     LogFile = "$($Log.ScriptPath)\$($Log.ScriptName)-$($Log.LogDate)-Log.txt"
# #     OutFile = "$($Log.ScriptPath)\$($Log.ScriptName)-$($Log.LogDate).txt"
# # }
# #endregion StandardObjects
    
#Script starts here
. $PSScriptRoot\New-IsoFile.ps1
Write-Host "IsoRootPAth :$IsoRoot" -ForegroundColor Cyan


#define extensions to install
$extensions = @(
    "dotjoshjohnson.xml"
    "grapecity.gc-excelviewer"
    "Gruntfuggly.todo-tree"
    "mechatroner.rainbow-csv"
    "ms-vscode.powershell"
    "oleg-shilo.favorites"
    "tomoki1207.pdf"
    "TylerLeonhardt.vscode-inline-values-powershell"
    "vscode-icons-team.vscode-icons"
)
# define sources
$vsCodeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
$SnippetSource = "$PSScriptRoot\Config\powershell.json"
$SettingsSource = "$PSScriptRoot\Config\settings.json"

#define paths
$DownloadPath = "$IsoRoot\Downloads"
$VscodeZipPath = "$DownloadPath\vscode.zip"
$extractPath = "$IsoRoot\vscode"
$dataPath = "$extractPath\data"
$SettingsDestination = "$IsoRoot\vscode\data\user-data\User\settings.json"
$SnippetDestination = "$IsoRoot\vscode\data\user-data\User\snippets\powershell.json"

if (-Not (Test-Path -Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath | Out-Null
}

# Cleanup previous installation
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}
break
# Download the latest VS Code zip
# Invoke-WebRequest -Uri $vsCodeUrl -OutFile $VscodeZipPath 
write-host "Downloading VS Code from $vsCodeUrl" -ForegroundColor Cyan

$Webclient = New-Object net.webclient
$Webclient.Downloadfile($vsCodeUrl, $VscodeZipPath)        

if (-Not (Test-Path $VscodeZipPath)) {
    Write-Host "Error: Ensure VS Code is downloaded correctly." -ForegroundColor Red
    exit 1
}


# Extract VS Code to the target location
Write-Host "Extracting VS Code to $extractPath" -ForegroundColor Cyan
Expand-Archive -Path $VscodeZipPath -DestinationPath $extractPath -Force

# Ensure the data folder exists
if (-Not (Test-Path $dataPath)) {
    New-Item -ItemType Directory -Path $dataPath | Out-Null
    write-host "Created data folder at $dataPath" -ForgrundColor Cyan
}

# Install extensions
write-host "Installing extensions..." -ForegroundColor Cyan
if (-Not (Test-Path "$extractPath\bin\code.cmd")) {
    Write-Host "Error: code.cmd not found in $extractPath\bin. Ensure VS Code is extracted correctly." -ForegroundColor Red
    exit 1
}
# $codeExecutable = "$extractPath\Code.exe"
foreach ($ext in $extensions) {
    &  $extractPath\bin\code.cmd "$extractPath\resources\app\out\cli.js" --install-extension $ext --extensions-dir "$dataPath\extensions" --force
}

# copy snippets
if ((Test-Path $SnippetSource)) {
    if (-Not (Test-Path $SnippetDestination)) {
        $NewItem = [ordered]@{
            Name     = ($SnippetDestination | Split-Path -Parent  | Split-Path -Leaf) 
            Path     = ($SnippetDestination | Split-Path -Parent  | Split-Path -Parent)
            ItemType = 'Directory'
        }
        New-Item @NewItem        
    }

    Copy-Item -Path $SnippetSource -Destination $SnippetDestination -Force -ErrorAction Stop
    write-host "Snippets copied to $SnippetDestination" -ForegroundColor Cyan
}


# copy VsCode Settings 

Copy-Item -Path $SettingsSource -Destination $SettingsDestination -Force
write-host "Settings copied to $SettingsDestination" -ForegroundColor Cyan


#Script ends here
# $Log.StopTime = Get-Date
# Write-Host
# Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
# $br | Out-Null