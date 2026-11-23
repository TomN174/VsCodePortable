# Write-Host "$(get-date -Format $DateSql) - BitlockerAdditionalDrives: please wait... ⏳" -ForegroundColor Cyan


# $BitlockerAdditionalDrives = $true

# if ($BitlockerAdditionalDrives) {
#     Write-Host "$(get-date -Format $DateSql) - BitlockerAdditionalDrives: finished ... ✅" -ForegroundColor Cyan
#     # $RegionResults.BitlockerAdditionalDrives = $true
# }

# else {
#     Write-Warning "$(get-date -Format $DateSql) - BitlockerAdditionalDrives: failed ... ❌"
# }
# Get-Culture

function Write-Message {
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Message = "Test Action",
          # Default message
        [Parameter(Mandatory = $true, ParameterSetName = 'wait')]
        [switch]$Wait,

        [Parameter(Mandatory = $true, ParameterSetName = 'finished')]
        [switch]$Finished,

        [Parameter(Mandatory = $true, ParameterSetName = 'failed')]
        [switch]$Failed,

        [Parameter(Mandatory = $true, ParameterSetName = 'error')]
        [switch]$Error
    )

    $DateSql = "yyyy-MM-dd HH:mm:ss"
    $DateString = Get-Date -Format $DateSql

    # Set sensible defaults depending on the selected parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'wait' {
            Write-Host "[ $DateString ] $($Message) : please wait... ⏳" -ForegroundColor Cyan
        }
        'finished' {
            Write-Host "[ $DateString ] $($Message) : finished ... " -NoNewline -ForegroundColor Cyan
            Write-Host "✅" -ForegroundColor Green
        }
        'failed' {
        Write-Warning "[ $DateString ] $($Message) : failed ... ❌❌❌"
        }
        'error' {
            # Write-Error "[ $DateString ] $($Message) :  error ... ❗" 
            Write-Error -Exception "[ $DateString ] $($Message) :  error ... ❗" 
        }
    }
}       
