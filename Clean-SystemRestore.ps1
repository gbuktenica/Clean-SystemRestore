#region Header
<#  
.SYNOPSIS  
    Delete all System Restore points older than the Machine Password

.DESCRIPTION
    Reads the age of the Domain Machine Password and deletes all System restore points that are older.
    Prevents a client performing a System Restore with an old Domain Machine Password and preventing access. 
    Domain Machine Password reset is configured by a domain level group policy at:
    Computer Configuration\Windows Settings\Security Settings\Local Policies\Security Options
    Domain member: Maximum machine account password age 
    Must be run UAC: Elevated

.PARAMETER [integer] MaxAge
    The age in days before a system restore point is deleted if domain controllers are not contactable.
    Default value 60 days.

.EXAMPLE
    Clean-SystemRestore.ps1
    Will delete all system restore points older than machine password or 60 days if offline and creates a new one if none exist.

.EXAMPLE
    Clean-SystemRestore.ps1 -MaxAge 30
    Will delete all system restore points older than machine password or 30 days if offline and creates a new one if none exist.

.NOTES  
    Author     : Glen Buktenica
	Change Log : 20151029 Initial Build  
               : 20151112 Update to read Machine Password Age 
               : 20151116 Try Catch for LDAP in case computer is not connected to WAN
               : 20160521 Updated formating and changed fixed MaxAge variable to Parameter
               
    License    : The MIT License (MIT)  
                 http://opensource.org/licenses/MIT  
  
.LINK 
    http://blog.buktenica.com/issues-with-domain-membership-after-system-restore/ 
#> 
Param(
     [int]$MaxAge = 60
     )
#region Functions
Function Delete-ComputerRestorePoints
{
<#
.SYNOPSIS
    Function to Delete Windows System Restore points
        
.DESCRIPTION
	Deletes Windows System Restore point(s) passed as an argument or via pipeline
    
.PARAMETER restorePoints
    Restore point(s) to be deleted (retrieved and optionally filtered from Get-ComputerRestorePoint
    
.EXAMPLE  
    Get-ComputerRestorePoint | Delete-ComputerRestorePoints -WhatIf	 
#>
	[CmdletBinding(SupportsShouldProcess=$True)]param(  
	    [Parameter(
	        Position=0, 
	        Mandatory=$true, 
	        ValueFromPipeline=$true
		)]
	    $restorePoints
	)
	begin
    {
		$fullName="SystemRestore.DeleteRestorePoint"
		#check if the type is already loaded
		$isLoaded=([AppDomain]::CurrentDomain.GetAssemblies() | foreach {$_.GetTypes()} | where {$_.FullName -eq $fullName}) -ne $null
		If (!$isLoaded)
        {
			$SRClient= Add-Type   -memberDefinition  @"
		    	[DllImport ("Srclient.dll")]
		        public static extern int SRRemoveRestorePoint (int index);
"@  -Name DeleteRestorePoint -NameSpace SystemRestore -PassThru
		}
	}
	process
    {
		foreach ($restorePoint in $restorePoints)
        {
			If($PSCmdlet.ShouldProcess("$($restorePoint.Description)","Deleting Restorepoint")) 
            {
		 		[SystemRestore.DeleteRestorePoint]::SRRemoveRestorePoint($restorePoint.SequenceNumber)
			}
		}
	}
}
#endregion Functions
#endregion Header
#region Main
# Determine current Machine Password age
Try
{
    $Searcher=[adsiSearcher]"(&(ObjectClass=Computer)(Name=$env:COMPUTERNAME))"
    $Searcher.PropertiesToLoad.AddRange('pwdLastSet')
    $Searcher.FindAll() | %{$PasswordLastSet=[datetime]::FromFileTime($_.Properties['pwdlastset'][0])}
}
Catch 
# If off the domain set password to max age.
{
    $PasswordLastSet = (Get-Date).AddDays(-($MaxAge))
}

# Add one day as script is only run daily.
$PasswordLastSet = $PasswordLastSet.AddDays(1)

# Remove old System Restore Points
Get-ComputerRestorePoint | Where {$_.ConvertToDateTime($_.CreationTime) -lt  $PasswordLastSet} | Delete-ComputerRestorePoints  

# If all System Restore points have been deleted create a new one.
If (!(Get-ComputerRestorePoint))
{
    CheckPoint-Computer -Description "Netlogon\Clean-SystemRestore.ps1"
}
#endregion Main
