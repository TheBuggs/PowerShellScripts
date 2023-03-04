param(
    [string] $FilePath,
    [string] $SoftwareName
)

$Names = Get-Content -Path $FilePath

foreach($Name in $Names){
    
    if(Test-Connection $Name -Count 1 -Quiet) {
        
        Invoke-Command -ComputerName $Name -ArgumentList $Name -ScriptBlock {
            param(
                [string]$Name = $Name
            )

            $e = Get-WmiObject -Class Win32_Product | Where-Object { if($_.Name -Like "*$SoftwareName*") {return $true} }

            if($e){
                
                Write-Host $Name " Y" -ForegroundColor Green
            }else{ 

                Write-Host $Name " N" -ForegroundColor Red
            }
            
        }
    }else{

        Write-Host $Name " OFF" -ForegroundColor Yellow
    }
}