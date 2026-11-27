# 자막자동 감시 스크립트 (5분마다 작업 스케줄러가 실행)
# 하는 일: 구글 드라이브 「자막자동\요청.txt」의 줄을 읽어, 형식이 맞는 줄만 yt-dlp로 처리.
#   sub  영상ID                     -> 한국어 자막
#   clip 영상ID 01:44-02:33 이름    -> 그 구간만 mp4 클립
# 다른 명령은 절대 실행하지 않음 (영상ID·시간·이름은 정해진 글자만 허용).
$ErrorActionPreference = 'Continue'
$errLog = Join-Path $env:USERPROFILE 'yt-sub\error.txt'
$mutex = $null
try { $mutex = New-Object System.Threading.Mutex($false, 'Local\ytsub-watcher'); if (-not $mutex.WaitOne(0)) { exit } } catch { $mutex = $null }
try {
$state = Join-Path $env:USERPROFILE 'yt-sub'
$doneFile = Join-Path $state 'done.txt'
$src = Join-Path $env:USERPROFILE 'OneDrive\Desktop\승리\쇼츠원본'
$subDir = Join-Path $src '자막'; $clipDir = Join-Path $src 'clips'
New-Item -ItemType Directory -Force $subDir, $clipDir | Out-Null

# 구글 드라이브 폴더 찾기
$g = $null
$roots = @((Get-PSDrive -PSProvider FileSystem | ForEach-Object { $_.Root }) + $env:USERPROFILE)
foreach ($r in $roots) {
  foreach ($n in @('내 드라이브', 'My Drive')) {
    $p = Join-Path $r $n
    if (Test-Path $p) { $g = $p; break }
  }
  if ($g) { break }
}
if (-not $g) { Write-Host 'Google Drive folder not found'; Add-Content $errLog ((Get-Date).ToString() + ' drive not found') ; exit }
Write-Host "Drive folder: $g"
$box = Join-Path $g '자막자동'; $res = Join-Path $box '결과'
New-Item -ItemType Directory -Force $box, $res | Out-Null
$req = Join-Path $box '요청.txt'
$log = Join-Path $box '상태.txt'
function Log($m) { Add-Content -Path $log -Value ("{0}  {1}" -f (Get-Date -Format 'MM-dd HH:mm'), $m) -Encoding UTF8 }
Set-Content -Path (Join-Path $box 'PC_마지막확인.txt') -Value (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -Encoding UTF8
if (-not (Test-Path $req)) { exit }

$done = @{}
if (Test-Path $doneFile) { Get-Content $doneFile -Encoding UTF8 | ForEach-Object { $done[$_] = 1 } }
$ID = '([A-Za-z0-9_-]{11})'
$TM = '(\d{1,2}:\d{2}(?::\d{2})?)'

function Make-Txt($vtt, $id, $title) {
  $out = New-Object System.Collections.Generic.List[string]
  $out.Add("[자막] $title"); $out.Add("https://youtu.be/$id")
  $t = '00:00'; $prev = ''
  foreach ($l in (Get-Content $vtt -Encoding UTF8)) {
    if ($l -match '^(\d+):(\d\d):(\d\d)\.\d+\s+-->') { $t = '{0:D2}:{1}' -f ([int]$Matches[1] * 60 + [int]$Matches[2]), $Matches[3]; continue }
    if ($l -match '-->') { continue }
    $x = ($l -replace '<[^>]+>', '').Trim()
    if ($x -eq '' -or $x -eq 'WEBVTT' -or $x -match '^(Kind|Language|NOTE|STYLE)\b') { continue }
    if ($x -ne $prev) { $out.Add("[$t] $x"); $prev = $x }
  }
  return ($out -join "`r`n")
}

foreach ($raw in (Get-Content $req -Encoding UTF8)) {
  $line = $raw.Trim()
  if ($line -eq '' -or $line.StartsWith('#') -or $done.ContainsKey($line)) { continue }
  $ok = $false
  if ($line -match "^sub\s+$ID$") {
    $id = $Matches[1]
    Set-Location $subDir
    Get-ChildItem -Path $subDir -Filter "$id.*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    & yt-dlp --skip-download --write-subs --write-auto-subs --sub-langs ko --sub-format vtt `
      --print-to-file '%(title)s' "$id.title.txt" --no-simulate -q --no-warnings `
      -o '%(id)s' "https://www.youtube.com/watch?v=$id" 2>$null | Out-Null
    $vtt = Get-ChildItem -Path $subDir -Filter "$id*.vtt" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($vtt) {
      $title = ''; if (Test-Path "$subDir\$id.title.txt") { $title = Get-Content "$subDir\$id.title.txt" -Encoding UTF8 | Select-Object -First 1 }
      Set-Content -Path "$res\$id.txt" -Value (Make-Txt $vtt.FullName $id $title) -Encoding UTF8
      Copy-Item -Force $vtt.FullName "$res\$($vtt.Name)"
      Log "자막 완료 $id"; $ok = $true
    } else { Log "자막 실패 $id (한국어 자막 없음 또는 잠시 막힘)" }
  }
  elseif ($line -match "^clip\s+$ID\s+$TM-$TM\s+([0-9A-Za-z가-힣_-]{1,40})$") {
    $id = $Matches[1]; $a = $Matches[2]; $b = $Matches[3]; $name = $Matches[4]
    $outFile = Join-Path $clipDir "$name.mp4"
    Remove-Item -Force $outFile -ErrorAction SilentlyContinue
    & yt-dlp -q --no-warnings -f 'bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[height<=1080]/b' `
      --download-sections "*$a-$b" --force-keyframes-at-cuts --merge-output-format mp4 `
      -o "$clipDir\$name.%(ext)s" "https://www.youtube.com/watch?v=$id" 2>$null | Out-Null
    if (Test-Path $outFile) { Copy-Item -Force $outFile "$res\$name.mp4"; Log "클립 완료 $name ($id $a-$b)"; $ok = $true }
    else { Log "클립 실패 $name ($id $a-$b)" }
  }
  else { Log "형식이 안 맞아 건너뜀: $line"; $ok = $true }
  if ($ok) { Add-Content -Path $doneFile -Value $line -Encoding UTF8; $done[$line] = 1 }
}
} catch { Write-Host $_; Add-Content $errLog ((Get-Date).ToString() + ' ' + $_) } finally { if ($mutex) { try { $mutex.ReleaseMutex() } catch {} } }
Write-Host 'watcher run finished'
