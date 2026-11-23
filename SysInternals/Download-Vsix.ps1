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
# $downloadDir = Join-Path $env:TEMP "vscode-vsix"
$downloadDir = Join-Path 'C:\Temp' "vscode-vsix"

New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null

$codeExe = if (Get-Command code -ErrorAction SilentlyContinue) { "code" }
           elseif (Get-Command code.cmd -ErrorAction SilentlyContinue) { "code.cmd" }
           else { throw "VS Code CLI not found. Ensure 'code' is on PATH." }

function Get-VsixFromOpenVsx {
    param($Publisher, $ExtensionName, $OutputPath)
    
    # Try open-vsx.org API (free alternative to VS Marketplace)
    $openVsxUrl = "https://open-vsx.org/api/$Publisher/$ExtensionName/latest/file"
    'https://open-vsx.org/api/DotJoshJohnson/xml/2.5.1/file/DotJoshJohnson.xml-2.5.1.vsix'
    https://open-vsx.org/api/vscode-icons-team/vscode-icons/12.18.0/file/vscode-icons-team.vscode-icons-12.18.0.vsix
    
    try {
        $response = Invoke-WebRequest -Uri $openVsxUrl -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
        if ($response.Content.Length -gt 1000) {
            [System.IO.File]::WriteAllBytes($OutputPath, $response.Content)
            return $true
        }
    } catch {
        return $false
    }
}

# Step 1: Download all VSIX files
Write-Host "=== Step 1: Downloading VSIX files ===" -ForegroundColor Cyan

foreach ($extension in $extensions) {
    $parts = $extension -split '\.', 2
    if ($parts.Count -ne 2) {
        Write-Warning "Skipping invalid extension identifier: $extension"
        continue
    }

    $publisher = $parts[0]
    $extensionName = $parts[1]
    $vsixFile = Join-Path $downloadDir "$publisher.$extensionName.vsix"

    Write-Host "Downloading $extension ..."

    # Try old Marketplace API first
    $downloadUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$extensionName/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
    $downloadUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$extensionName/12.18.0
    $downloadUrl
    $success = $false

    try {
        $response = Invoke-WebRequest -Uri $downloadUrl -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
        
        # Check if we got actual VSIX content
        if ($response.Content.Length -gt 1000) {
            [System.IO.File]::WriteAllBytes($vsixFile, $response.Content)
            $success = $true
            Write-Host "  Saved (Marketplace): $vsixFile" -ForegroundColor Green
        }
    } catch {
        Write-Host "  Marketplace failed, trying open-vsx.org..." -ForegroundColor Yellow
    }

    # Fallback to open-vsx.org
    if (-not $success) {
        $success = Get-VsixFromOpenVsx -Publisher $publisher -ExtensionName $extensionName -OutputPath $vsixFile
        if ($success) {
            Write-Host "  Saved (open-vsx): $vsixFile" -ForegroundColor Green
        }
    }

    if (-not $success) {
        Write-Warning "  Failed to download $extension"
    }
}
break
# Step 2: Install from downloaded files
Write-Host "`n=== Step 2: Installing from downloaded VSIX files ===" -ForegroundColor Cyan

$downloadedFiles = Get-ChildItem -Path $downloadDir -Filter "*.vsix" -ErrorAction SilentlyContinue

if ($downloadedFiles) {
    foreach ($vsix in $downloadedFiles) {
        Write-Host "Installing $($vsix.Name) ..."
        try {
            & $codeExe --install-extension $vsix.FullName --force
            Write-Host "  Installed: $($vsix.Name)" -ForegroundColor Green
        } catch {
            Write-Warning "  Failed to install $($vsix.Name): $_"
        }
    }
} else {
    Write-Warning "No VSIX files found to install"
}

Write-Host "`nDone." -ForegroundColor Green
