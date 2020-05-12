$matchList = Import-Csv -Path .\eng.1.csv

Write-Host "Match results for Arsenal`n"
foreach ($something in $matchList){
    if($something.'Team 1' -match "Arsenal"){
        Write-Host $something.'Team 2' " "$something.FT
    }
}