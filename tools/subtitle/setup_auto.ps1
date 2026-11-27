# One-time setup for automatic subtitles/clips. ASCII only on purpose.
$base = 'https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/3b7a0d70dd289fdc5640d8a0bf5a486156818ea6/tools/subtitle'
$dir = Join-Path $env:USERPROFILE 'yt-sub'
New-Item -ItemType Directory -Force $dir | Out-Null
Invoke-WebRequest -UseBasicParsing "$base/watch.ps1" -OutFile (Join-Path $dir 'watch.ps1')
$vbs = 'CreateObject("WScript.Shell").Run "powershell -NoProfile -ExecutionPolicy Bypass -File ""' + (Join-Path $dir 'watch.ps1') + '""", 0, False'
[IO.File]::WriteAllText((Join-Path $dir 'watch.vbs'), $vbs, [Text.Encoding]::ASCII)
$act = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument ('"' + (Join-Path $dir 'watch.vbs') + '"')
$t1 = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5)
$t2 = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$set = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
Register-ScheduledTask -TaskName 'ytsub-watcher' -Action $act -Trigger $t1, $t2 -Settings $set -Force | Out-Null
$ok = $true
if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) { Write-Host 'yt-dlp not found: winget install yt-dlp.yt-dlp' -ForegroundColor Red; $ok = $false }
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) { Write-Host 'ffmpeg not found (clips need it): winget install Gyan.FFmpeg' -ForegroundColor Yellow }
$naeDrive = -join ([char]0xB0B4, ' ', [char]0xB4DC, [char]0xB77C, [char]0xC774, [char]0xBE0C)
$gd = $false
$roots = @((Get-PSDrive -PSProvider FileSystem | ForEach-Object { $_.Root }) + $env:USERPROFILE)
foreach ($r in $roots) { if ((Test-Path (Join-Path $r 'My Drive')) -or (Test-Path (Join-Path $r $naeDrive))) { $gd = $true } }
if (-not $gd) {
  $ok = $false
  Write-Host 'Google Drive folder not found. Open the Google Drive app from the Start menu, sign in, wait 1 minute, then run this line again.' -ForegroundColor Red
  Write-Host '--- check info (send a screenshot) ---' -ForegroundColor Yellow
  $proc = Get-Process -Name GoogleDriveFS -ErrorAction SilentlyContinue
  Write-Host ('Drive app running: ' + [bool]$proc)
  foreach ($d in (Get-PSDrive -PSProvider FileSystem)) { Write-Host ('Drive ' + $d.Root + ' : ' + ((Get-ChildItem $d.Root -Directory -ErrorAction SilentlyContinue | Select-Object -First 6 -ExpandProperty Name) -join ', ')) }
  foreach ($k in 'HKCU:\Software\Google\DriveFS', 'HKLM:\SOFTWARE\Google\DriveFS') { if (Test-Path $k) { Get-ItemProperty $k | Select-Object * -ExcludeProperty PS* | Format-List | Out-String | Write-Host } }
}
if ($ok) { Write-Host 'OK! Auto subtitle is running (every 5 min).' -ForegroundColor Green }
Write-Host 'First run now (may take a few minutes)...' -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dir 'watch.ps1')
