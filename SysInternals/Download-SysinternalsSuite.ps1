<#

		Author: ohnauma
		Version: 1.1
		Version History:
		Purpose:
#>
#requires -Version 5
<#
		[cmdletBinding(
		SupportsShouldProcess=$true,	
		ConfirmImpact='High'
		)]

#>

Param(
	[Parameter(Mandatory=$false)]
	[boolean]
	#$logging = $true
	$logging = $false
	<#,

			[String]
			[Parameter(Mandatory=$false)]
			$Site,

			[string]
			[Parameter(Mandatory=$false)]
			$OuPath ='OU=brose,dc=brose,dc=net'
	#>
)

#region  ######## Toms Variables#######	
$Scriptpath =  Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ScriptName =$MyInvocation.MyCommand.Name

$Log = New-Object -TypeName PSObject
$Log | Add-Member -MemberType NoteProperty -Name LogDate -Value ('{0:yyyy.MM.dd_HH.mm.ss}' -f (Get-Date))
$Log | Add-Member -MemberType NoteProperty -Name ScriptAlias -Value '001-LosGehts'
$Log | Add-Member -MemberType NoteProperty -Name ScriptName -Value $ScriptName
$Log | Add-Member -MemberType NoteProperty -Name ScriptPath -Value $ScriptPath
$Log | Add-Member -MemberType NoteProperty -Name UserID -Value $env:USERNAME
$Log | Add-Member -MemberType NoteProperty -Name Computername -Value  $env:COMPUTERNAME
$Log | Add-Member -MemberType NoteProperty -Name ExcSrv -Value  $env:COMPUTERNAME
$Log | Add-Member -MemberType NoteProperty -Name Error -Value 0
$Log | Add-Member -MemberType NoteProperty -Name Site -Value '###'

$tn = New-Object -TypeName PSObject
$tn | Add-Member -MemberType NoteProperty -Name LogFile -Value ($Log.ScriptPath + '\' + $Log.ScriptName + '-' + $Log.LogDate + '-Log.txt')
$tn | Add-Member -MemberType NoteProperty -Name OutFile -Value ($Log.ScriptPath + '\' + $Log.ScriptName + '-' + $Log.LogDate + '.txt')
#endregion ########End Toms Variables#######

#region trap
trap {
	$Log.Error = $Error[0].Exception.Message.Replace("'",' ')
	#$Log.Error = $Error[0].Exception.Message
	$Log
	if ($logging)
	{
		#Write-LogSQL $Log
	}
	break
}
#endregion ######## trap ########

$DestinationPath = 'C:\SysInternals'
Remove-Item "$DestinationPath\*.*" -Exclude '*.bgi'

$DestinationFile = $DestinationPath + '\Sysinternals.zip'
Invoke-WebRequest 'https://download.sysinternals.com/files/SysinternalsSuite.zip' -OutFile $DestinationFile
#Expand-Archive -Path $DestinationFile -

Set-Content -Value "Last update on $($Log.LogDate)" -Path $DestinationPath\000-Update.txt
Expand-Archive -Path $DestinationFile -DestinationPath $DestinationPath 




if ($logging)
{
	#Write-LogSQL $Log
}

