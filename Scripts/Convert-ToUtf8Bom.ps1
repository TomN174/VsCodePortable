<#
.SYNOPSIS
    Converts files in a workspace to UTF-8 with BOM.

.DESCRIPTION
    This script scans all files in the specified workspace and:
    - Detects whether they are encoded in UTF-8.
    - Adds a UTF-8 BOM if missing.
    - Optionally converts non-UTF-8 files (e.g., ANSI/Windows-1252) into UTF-8 with BOM
      when the -ConvertNonUtf8 switch is provided.

.PARAMETER workspace
    The path to the workspace folder to process.

.PARAMETER ConvertNonUtf8
    Optional switch. If set, non-UTF-8 files will also be converted to UTF-8 with BOM.
    By default, only UTF-8 files without BOM are rewritten.

.EXAMPLE
    .\Convert-ToUtf8Bom.ps1 -workspace "C:\Projects\MyCode"

    Converts only UTF-8 files without BOM in the given workspace.

.EXAMPLE
    .\Convert-ToUtf8Bom.ps1 -workspace "C:\Projects\MyCode" -ConvertNonUtf8

    Converts all files, including non-UTF-8, into UTF-8 with BOM.

.NOTES
    Author: Thomas
    Created: November 2025
    Safe by default — only modifies UTF-8 files missing BOM unless -ConvertNonUtf8 is used.
#>

param(
    [string]$workspace = "C:\path\to\your\workspace",
    [switch]$ConvertNonUtf8   # Pass -ConvertNonUtf8 if you want ANSI/other encodings converted
)

# Define UTF-8 BOM bytes
$utf8Bom = [byte[]](0xEF,0xBB,0xBF)

# Encoding object with BOM
$utf8BomEncoding = New-Object System.Text.UTF8Encoding($true)

# Helper: check if byte array is valid UTF-8
function Test-IsUtf8 {
    param([byte[]]$bytes)

    try {
        [System.Text.Encoding]::UTF8.GetString($bytes) | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Process files (adjust extensions as needed)
Get-ChildItem -Path $workspace -Recurse -Include *.txt, *.ps1, *.cs, *.json | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)

    # Check for BOM
    $hasBom = $false
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $hasBom = $true
    }

    # Check if file is valid UTF-8
    $isUtf8 = Test-IsUtf8 $bytes

    if ($isUtf8 -and -not $hasBom) {
        Write-Host "Rewriting $($_.FullName) as UTF-8 with BOM..."
        $content = [System.Text.Encoding]::UTF8.GetString($bytes)
        [System.IO.File]::WriteAllText($_.FullName, $content, $utf8BomEncoding)
    }
    elseif ($isUtf8 -and $hasBom) {
        Write-Host "Skipping $($_.FullName) (already UTF-8 with BOM)"
    }
    elseif (-not $isUtf8 -and $ConvertNonUtf8) {
        Write-Host "Converting $($_.FullName) from default encoding to UTF-8 with BOM..."
        # Assume system default encoding (ANSI/Windows-1252) for non-UTF8 files
        $content = [System.Text.Encoding]::Default.GetString($bytes)
        [System.IO.File]::WriteAllText($_.FullName, $content, $utf8BomEncoding)
    }
    else {
        Write-Host "Skipping $($_.FullName) (not UTF-8, and ConvertNonUtf8 not set)"
    }
}
