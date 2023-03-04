param(
    [string] $ComputerName,
    [string] $ServiceName
)

$service = Get-Service -ComputerName $ComputerName -Name $ServiceName