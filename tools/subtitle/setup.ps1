# One-time setup: installs the "jamak-badgi" (subtitle) shortcut on the Desktop. ASCII only on purpose.
$base = 'https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/3b7a0d70dd289fdc5640d8a0bf5a486156818ea6/tools/subtitle'
$home2 = Join-Path $env:USERPROFILE 'yt-sub'
New-Item -ItemType Directory -Force $home2 | Out-Null
Invoke-WebRequest -UseBasicParsing "$base/get.ps1" -OutFile (Join-Path $home2 'get.ps1')
$name = (-join ([char]0xC790, [char]0xB9C9, [char]0xBC1B, [char]0xAE30)) + '.bat'
$desk = [Environment]::GetFolderPath('Desktop')
$bat = "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\yt-sub\get.ps1""`r`n"
[IO.File]::WriteAllText((Join-Path $desk $name), $bat, [Text.Encoding]::ASCII)
if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) { Write-Host 'yt-dlp not found. Run: winget install yt-dlp.yt-dlp' -ForegroundColor Red }
else { Write-Host 'OK! Desktop shortcut created.' -ForegroundColor Green }
