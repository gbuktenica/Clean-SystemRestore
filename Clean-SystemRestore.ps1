<#  
.SYNOPSIS  
    Delete all System Restore points older than 60 days

.INPUTS
    None. You cannot pipe objects to this function.

.OUTPUTS
    None. 

.NOTES  
    Author     : Glen Buktenica
	Change Log : Initial Build  20151029
#> 

#
# Script variables
#

    # Maximum age in days that a restore point can be before deletion.
    $MaxAge = 60

########################
#                      #
# Functions start here #
#                      #
########################
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
    Get-ComputerRestorePoint | Delete-ComputerRestorePoints	 

.NOTES  
    Author     : Dirk_74
	Change Log : Initial Build  20130608

.LINK
    https://gallery.technet.microsoft.com/scriptcenter/Script-to-delete-System-4960775a
#>
	[CmdletBinding(SupportsShouldProcess=$True)]param(  
	    [Parameter(
	        Position=0, 
	        Mandatory=$true, 
	        ValueFromPipeline=$true
		)]
	    $restorePoints
	)
	begin{
		$fullName="SystemRestore.DeleteRestorePoint"
		#check if the type is already loaded
		$isLoaded=([AppDomain]::CurrentDomain.GetAssemblies() | foreach {$_.GetTypes()} | where {$_.FullName -eq $fullName}) -ne $null
		if (!$isLoaded){
			$SRClient= Add-Type   -memberDefinition  @"
		    	[DllImport ("Srclient.dll")]
		        public static extern int SRRemoveRestorePoint (int index);
"@  -Name DeleteRestorePoint -NameSpace SystemRestore -PassThru
		}
	}
	process{
		foreach ($restorePoint in $restorePoints){
			if($PSCmdlet.ShouldProcess("$($restorePoint.Description)","Deleting Restorepoint")) {
		 		[SystemRestore.DeleteRestorePoint]::SRRemoveRestorePoint($restorePoint.SequenceNumber)
			}
		}
	}
}

#########################
#                       #
# Main Body starts here #
#                       #
#########################
$RemoveDate = (Get-Date).AddDays(-($MaxAge))
Get-ComputerRestorePoint | Where { $_.ConvertToDateTime($_.CreationTime) -lt  $RemoveDate } | Delete-ComputerRestorePoints 
