
param(
    [string]$Usename,           #Example: aduser
    [string]$NetworkDirectory,  #Example: \\srv\dir
    [string]$MapDrive,          #Example: AD Group like MapDriveSecurityGroup
    [string]$Letter = 'U:'      #Example: U:
)

# 1. Create homefolder for spcific user account
function CreateHomeFolder {
	param (
		[string]$user
	)
	
	$adUser = Get-ADUser -Filter {sAMAccountName -eq $user}   
    
	if ($adUser -ne $Null) {	
		
		$homeDirectory = '{0}\{1}' -f $NetworkDirectory, $user
        Set-ADUser -Identity $user -HomeDirectory $homeDirectory -HomeDrive $Letter
		return $true
	}
	
	return $false
}

# 2. Set other permission to homefoder
function ChangePermissionFolder {
	param (
		[string] $Name,
        [string] $Domain,
        [string] $Path,
        [string] $Acounts = @()
	)

    $User = $Name
    $FullDir = "{0}\{1}" -f $Path, $User

	$HomeFolderACL = Get-Acl -Path .\test
    $HomeFolderACL.SetAccessRuleProtection($true, $false)

    $DomainAdmin = "{0}\Domain Admins" -f $Domain
    # Test account
    $OtherAccount = "{0}\test"  

    $List = @("SYSTEM", "BUILTIN\Administrators", "minedu\Domain Admins")
    
    $List | ForEach-Object {
		$ACL = New-Object System.Security.AccessControl.FileSystemAccessRule($_,"FullControl", "ContainerInherit,ObjectInherit","None","Allow")
		$HomeFolderACL.AddAccessRule($ACL)
	}

	Set-Acl -Path $FullDir $HomeFolderACL
}


# 3. Add to security group where map current folder
function Add2GroupMapDrive {
    param (
		[string] $User,
        [string] $MapDrive
	)
	
	$AdUser = Get-ADUser -Filter {sAMAccountName -eq $User}
    $Group =  Get-ADGroup $MapDrive
    Add-ADGroupMember -Identity $Group -Members $AdUser

}

# Run
$success = $true
if(CreateHomeFolder $Usename){

    if(ChangePermissionFolder $Usename, $Domain, $Path, $Accounts ){

        if(Add2GroupMapDrive $Usename, $MapDrive){
            $success = $false
            Write-Host "Success"
        }
    }
}

if($success){
    Write-Host "Error"
}