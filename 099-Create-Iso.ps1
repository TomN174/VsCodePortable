<#
.SYNOPSIS
    Creates an ISO file from a specified source directory using a helper script.

.DESCRIPTION
    This script generates an ISO image containing the contents of a given folder. 
    It sets up default paths for the source directory and output location, 
    constructs a timestamped ISO filename, and invokes the New-ISOFile function 
    to perform the ISO creation. The helper script 'New-IsoFile.ps1' must be present 
    in the same directory as this script.

.PARAMETER IsoRoot
    The root directory whose contents will be included in the ISO file.

.PARAMETER OutputIsoDestinationPath
    The destination path where the generated ISO file will be saved.

.NOTES
    - Requires 'New-IsoFile.ps1' in the script directory.
    - The output ISO filename includes the current date and time for uniqueness.
    - Designed for use with Visual Studio Code portable tools packaging.

.EXAMPLE
    .\099-Create-Iso.ps1 -IsoRoot 'C:\MySource' -OutputIsoDestinationPath 'D:\MyIso'
    Creates an ISO file from 'C:\MySource' and saves it as 'D:\MyIso'.
#>
#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
    $IsoRoot = 'C:\ISO-VsCode',
    $OutputIsoDestinationPath = 'C:\ISO-VsCode-Out'
)

. $PSScriptRoot\New-IsoFile.ps1
#endregion Paramsection

#Script starts here
if (-not (Test-Path -Path $OutputIsoDestinationPath)) {
    New-Item -Path $OutputIsoDestinationPath -ItemType Directory | Out-Null
}

$OutputIsoName = "$(Get-Date -Format yyyy-MM-dd_HH-mm )_VsCodeTools"
$OutputIsoDestinationFilePath = "$OutputIsoDestinationPath\$($OutputIsoName).iso"

New-ISOFile -source $IsoRoot -destinationIso $OutputIsoDestinationFilePath  -title $OutputIsoName -Verbose -force 
