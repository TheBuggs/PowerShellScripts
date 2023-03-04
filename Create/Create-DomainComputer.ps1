param(
    [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [System.String]
    $computer,
    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
    [System.String]
    $name,
    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
    [System.String]
    $address,
    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
    [System.String]
    $WEB_PATH
)

# Path to json file with credentials
$path = "$WEB_PATH\PSScripts\settings.json"

#$testPath = Test-Path -Path $path

$conf = Get-Content -Path $path | ConvertFrom-Json

# Domain Admin Account
$cred = [pscredential]::new(
    $conf.user1,
    ($conf.pass1 | ConvertTo-SecureString -AsPlainText -Force)
)

# Local Admin Account
$cred2 = [pscredential]::new(

    $conf.user2,
    ($conf.pass2 | ConvertTo-SecureString -AsPlainText -Force)
)

# Throw excepton where in code. Default is false
$check = 0

# Check is a server. Default is true
$isServer = "TRUE"

# Check is a renamed. Default is FALSE
$isRenamed = "FALSE"

# MAC Address. Default is empty
$mac = ""

# IP Address. Default is empty
$ip= ""

# Unique number. Default is empty
$uuid = ""

$error       = ""
$warning     = ""
$information = ""

try{
   
   $computer = $computer -replace "\$", ""
   $OS = Get-ADComputer -Identity $computer -Properties * | Select OperatingSystem

   if($OS -notcontains "Server"){
   
        $a = Invoke-Command -ComputerName $computer -ScriptBlock {
            
            param(
                $address
            )

            $interfaces = Get-NetIPConfiguration | Select * #| Select IPv4Address, InterfaceIndex
            $results = @()
            
            # Get Unique ID fror all system in BIOS
            $uuid = get-wmiobject Win32_ComputerSystemProduct  | Select-Object -ExpandProperty UUID
            $uuid = ([string]($uuid)).Trim()
            
            foreach($interface in $interfaces){ 

                $adapterInfo = Get-NetAdapter -InterfaceIndex $interface.InterfaceIndex | Select *
                $addr    = $address.Trim()
                $macAddr = ([string]($adapterInfo.MacAddress)).Trim()
                $ipAddr  = ([string]($interface.IPv4Address)).Trim()

                if($ipAddr-Like $addr){

                    $hash = @{
                        macAddress = $macAddr
                        ipAddress = $ipAddr
                        uuid = $uuid
                    }
    
                    $results += New-Object PSObject -Property $hash
                } 
            }
            $results
        } -ArgumentList $address

        $mac   = $a.macAddress
        $ip    = $a.ipAddress
        $uuid  = $a.uuid
        $check = 1
        $isServer  = "FALSE"
        $isRenamed = "TRUE"
   }

}catch{
    
    $check = 0   
}

try{

    Rename-Computer -ComputerName $computer -NewName $name -LocalCredential $cred -DomainCredential $cred2 -ErrorAction Ignore -ErrorVariable $e -WarningAction Ignore -WarningVariable $w -InformationAction Ignore -InformationVariable $in -Force
    
    $error       = $e
    $warning     = $w
    $information = $i
    
    if($e){
     $isRenamed  = "FALSE"
     $check      = 0
     $null       = Write-Output "$(Get-Date)`t`tOld name $($computer)`t`tNew name $($name)`t`tERR TO RENAME $($error)"  >> "$WEB_PATH\PSLogs\renamecomuter-log.txt"
    }

    $isRenamed = "TRUE"

}catch{

    $isRenamed = "FALSE"
    $check = 0
}

try{
    if($check -eq 1){
        # Add Succes to log file
        $null = Write-Output "$(Get-Date)`t`tOld name $($computer)`t`tNew name $($name)`t`tSUCCESS $($error) $($isRenamed)" >> "$WEB_PATH\PSLogs\renamecomuter-log.txt"
    }else{
        # Add Error to log file
        $null = Write-Output "$(Get-Date)`t`tOld name $($computer)`t`tNew name $($name)`t`tERR TO RENAME $($error) $($isRenamed)" >> "$WEB_PATH\PSLogs\renamecomuter-log.txt"
    }
}catch{}

# MAC Format HH:HH:HH:HH
$mac = $mac.replace("-",":")

$params = @{
    "uuid"    = $uuid
    "mac"     = $mac
    "ip"      = $ip
    "server"  = $isServer
    "renamed" = $isRenamed
    "error"   = $error
}

return ConvertTo-Json -InputObject $params