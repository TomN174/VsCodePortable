<#
.SYNOPSIS
    Automates the download, extraction, and configuration of a portable Visual Studio Code installation with predefined extensions and settings.

.DESCRIPTION
    This script downloads the latest stable release of Visual Studio Code (portable version) for Windows, extracts it to a specified directory, installs a set of useful extensions, and applies custom user settings and PowerShell snippets. It ensures all necessary directories exist, cleans up previous installations, and provides progress feedback throughout the process.

.PARAMETER IsoRoot
    The root directory where VS Code and related files will be installed. Defaults to 'C:\ISO-VsCode'.

.NOTES
    - Requires internet access to download VS Code and extensions.
    - Inspired by LindnerBrewery/Emrys MacInally's VS Code automation scripts.
    - Tested on Windows platforms.

.LINK
    https://github.com/LindnerBrewery/PsConfEU2023_Docker/blob/main/Demo/install-vscodeserverAndExtensions.ps1

.EXAMPLE
    .\010-Get-vscode-Portable.ps1 -IsoRoot 'D:\VSCodePortable'

    Downloads and sets up VS Code portable in 'D:\VSCodePortable' with specified extensions and settings.
#>

#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
    $IsoRoot = 'C:\ISO-VsCode'
)
#endregion Paramsection


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

# Ensure the download directory exists
if (-Not (Test-Path -Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath -ErrorAction Stop| Out-Null
}

# Cleanup previous installation
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}
# break
# Download the latest VS Code zip
# Invoke-WebRequest -Uri $vsCodeUrl -OutFile $VscodeZipPath -UseBasicParsing
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
# inspired by LindnerBrewery/ Emrys MacInally
# https://github.com/LindnerBrewery/PsConfEU2023_Docker/blob/main/Demo/install-vscodeserverAndExtensions.ps1

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