<#
.SYNOPSIS
    Installs a predefined list of Visual Studio Code extensions using the VS Code CLI.

.DESCRIPTION
    This script automates the installation of a set of Visual Studio Code extensions by invoking the VS Code command-line interface (code.cmd).
    It checks for the existence of the VS Code CLI in the specified installation directory and installs each extension listed in the $extensions array.
    If the CLI is not found, the script displays an error message and exits.

.PARAMETER extensions
    An array of extension identifiers to be installed.

.PARAMETER extractPath
    The path to the VS Code installation directory.

.NOTES
    - Ensure that VS Code is properly extracted to the specified directory before running this script.
    - The script requires administrative privileges if installing to "C:\Program Files".
    - The '--force' flag is used to reinstall extensions if they are already present.

.EXAMPLE
    .\099-Install-Extension-InVsCode-ProgramfilesDir.ps1
#>

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

$extractPath = "C:\Program Files\Microsoft VS Code\"

if (-Not (Test-Path "$extractPath\bin\code.cmd")) {
    Write-Host "Error: code.cmd not found in $extractPath\bin. Ensure VS Code is extracted correctly." -ForegroundColor Red
    exit 1
}

write-host "Installing extensions..." -ForegroundColor Cyan
# $codeExecutable = "$extractPath\Code.exe"
foreach ($ext in $extensions) {
    # &  $extractPath\bin\code.cmd "$extractPath\resources\app\out\cli.js" --install-extension $ext --extensions-dir "$dataPath\extensions" --force
    &  $extractPath\bin\code.cmd "$extractPath\resources\app\out\cli.js" --install-extension $ext  --force
}