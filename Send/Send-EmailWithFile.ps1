$from = "test@organization.local"
$dest = "dest@organization.local"
$smtp = "mail@organization.local"
$subj = "Test"
$port = 25
$path = "C:\Users\user\Desktop\*.pdf"

$files = Get-ChildItem $path

$count = 0
$failed = @()

foreach ($file in $files){
    
    $name = $file.Name
    
    $a = Send-MailMessage -From $eami -To $dest -SmtpServer $smtp -Subject $subj -Attachment $file -Port $port
    
    if($a){
        
        Write-Host $count $file  -ForegroundColor Green
    
    }else{
       
        Write-Host $count $file -ForegroundColor Red

        $failed += $name
    }
    
    Start-Sleep -s 2
    
    $count = $count + 1
}

Write-Host "Count: " $count

# Show files with errors
$failed