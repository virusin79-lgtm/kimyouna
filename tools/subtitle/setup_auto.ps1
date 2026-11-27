# One-time setup for automatic subtitles/clips. ASCII only on purpose.
$base = 'https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/claude/project-thread-jejtqi/tools/subtitle'
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
$gd = $false; foreach ($d in (Get-PSDrive -PSProvider FileSystem)) { if ((Test-Path (Join-Path $d.Root 'My Drive')) -or (Get-ChildItem $d.Root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name.Length -eq 6 -and $_.Name.EndsWith([string][char]0xBE0C) })) { $gd = $true } }
if (-not $gd) { Write-Host 'Google Drive app not found. Install: https://www.google.com/drive/download/' -ForegroundColor Red; $ok = $false }
if ($ok) { Write-Host 'OK! Auto subtitle is running (every 5 min).' -ForegroundColor Green }
Start-ScheduledTask -TaskName 'ytsub-watcher'
