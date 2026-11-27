# 자막받기 - 클립보드의 유튜브 링크로 한국어 자막을 받아, 시간표시 텍스트로 클립보드에 복사
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$dir = Join-Path $env:USERPROFILE 'OneDrive\Desktop\승리\쇼츠원본\자막'
New-Item -ItemType Directory -Force $dir | Out-Null
Set-Location $dir
Add-Type -AssemblyName System.Windows.Forms
function Say($msg) { [System.Windows.Forms.MessageBox]::Show($msg, '자막받기') | Out-Null }

$url = ''
try { $url = (Get-Clipboard | Out-String).Trim() } catch {}
# 지난번 자막 글이 아직 복사돼 있으면(새 주소를 복사 안 했으면) 링크로 쓰지 않음
if ($url -match '^\[자막') { $url = '' }
if ($url.Length -gt 300) { $url = '' }
if ($url -notmatch '(youtube\.com|youtu\.be)') {
  Write-Host ''
  Write-Host '유튜브 링크를 먼저 복사한 뒤 다시 더블클릭해 주세요.' -ForegroundColor Yellow
  $url = Read-Host '또는 여기에 링크를 붙여넣고 Enter (마우스 오른쪽 클릭 = 붙여넣기)'
}
if ($url -notmatch '(?:v=|youtu\.be/|shorts/|live/|embed/)([A-Za-z0-9_-]{11})') {
  Say '유튜브 링크를 찾지 못했어요. 영상 주소를 복사(Ctrl+C)한 뒤 다시 더블클릭해 주세요.'; exit
}
$id = $Matches[1]
Write-Host ''
Write-Host "자막 받는 중... ($id)  잠깐만 기다려 주세요." -ForegroundColor Cyan
Get-ChildItem -Path $dir -Filter "$id.*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
& yt-dlp --skip-download --write-subs --write-auto-subs --sub-langs ko --sub-format vtt `
  --print-to-file '%(title)s' "$id.title.txt" --no-simulate -q --no-warnings `
  -o '%(id)s' "https://www.youtube.com/watch?v=$id" 2>$null | Out-Null

$vtt = Get-ChildItem -Path $dir -Filter "$id*.vtt" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $vtt) {
  Set-Clipboard -Value "[자막 실패] https://youtu.be/$id - 한국어 자막 없음 또는 잠시 막힘"
  Say "이 영상($id)은 한국어 자막을 못 받았어요.`n`n채팅창에 그대로 Ctrl+V 해서 보내 주시면 클로드가 알아서 할게요."; exit
}
$title = ''
if (Test-Path "$dir\$id.title.txt") { $title = (Get-Content "$dir\$id.title.txt" -Encoding UTF8 | Select-Object -First 1) }

$out = New-Object System.Collections.Generic.List[string]
$out.Add("[자막] $title")
$out.Add("https://youtu.be/$id")
$t = '00:00'; $prev = ''
foreach ($l in (Get-Content $vtt.FullName -Encoding UTF8)) {
  if ($l -match '^(\d+):(\d\d):(\d\d)\.\d+\s+-->') {
    $t = '{0:D2}:{1}' -f ([int]$Matches[1] * 60 + [int]$Matches[2]), $Matches[3]; continue
  }
  if ($l -match '-->') { continue }
  $x = ($l -replace '<[^>]+>', '').Trim()
  if ($x -eq '' -or $x -eq 'WEBVTT' -or $x -match '^(Kind|Language|NOTE|STYLE)\b') { continue }
  if ($x -ne $prev) { $out.Add("[$t] $x"); $prev = $x }
}
$text = $out -join "`r`n"
Set-Content -Path "$dir\$id.txt" -Value $text -Encoding UTF8
Set-Clipboard -Value $text
Say "자막 복사 완료! ($($out.Count - 2)줄)`n영상: $title`n`n클로드 채팅창을 누르고 Ctrl+V → 보내기만 하면 돼요."
