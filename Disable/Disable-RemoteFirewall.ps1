param(
    [string] $ComputerName
)

Invoke-Command -ComputerName $ComputerName -ScriptBlock { 
   
   Set-NetFirewallProfile -Profile Domain,Private -Enabled False
   Get-NetFirewallProfile | Select *   
}

# Execute gpupdate /force to remote computer
#
# Get-adcomputer -Filter * Properties * | Where {$_.}
# Invoke-Command -ComputerName $ComputerName {
#   $cmd1 = "cmd.exe"
#   $arg1 = "/c"
#   $arg2 = "echo y | gpupdate /force /wait:0"
#   &$cmd1 $arg1 $arg2
# }