.SYNOPSIS  
    Delete all System Restore points older than the Machine Password

.DESCRIPTION
    Reads the age of the Domain Machine Password and deletes all System restore points that are older.
    Prevents a client performing a System Restore with an old Domain Machine Password and preventing access. 
    Domain Machine Password reset is configured by a domain level group policy at:
    Computer Configuration\Windows Settings\Security Settings\Local Policies\Security Options
    Domain member: Maximum machine account password age 

.INPUTS
    None. You cannot pipe objects to this function.

.OUTPUTS
    None. 

.NOTES  
Author     : Glen Buktenica
Change Log : Initial Build  20151029
       	   : Update to read Machine Password Age 20151112
