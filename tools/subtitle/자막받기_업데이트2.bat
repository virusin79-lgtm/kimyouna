@echo off
chcp 65001 >nul
title 자막받기 업데이트2
echo 자막받기 업데이트 중...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $d=Join-Path $env:USERPROFILE 'yt-sub'; New-Item -ItemType Directory -Force $d | Out-Null; $f=Join-Path $d 'watch.ps1'; Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/678cc5e30f4596242c2e27152ab0c91b0a11b994/tools/subtitle/watch.ps1' -OutFile $f; if (Select-String -Path $f -Pattern 'done2' -Quiet) { Write-Host 'NEW VERSION OK' -ForegroundColor Green } else { Write-Host 'STILL OLD VERSION' -ForegroundColor Red }; Write-Host ('file: ' + $f); Get-ScheduledTask ytsub-watcher | Select-Object -ExpandProperty Actions | Format-List Execute,Arguments"
echo.
echo ==== 이 창을 캡처해서 클로드에게 보내 주세요. ====
pause
