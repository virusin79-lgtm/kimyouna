@echo off
chcp 65001 >nul
title 자막받기 업데이트3
cd /d "%USERPROFILE%"
if not exist "%USERPROFILE%\yt-sub" mkdir "%USERPROFILE%\yt-sub"
echo 자막받기 새 버전 받는 중...
curl.exe -sSL -o "%USERPROFILE%\yt-sub\watch_new.ps1" https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/678cc5e30f4596242c2e27152ab0c91b0a11b994/tools/subtitle/watch.ps1
findstr /c:"done2" "%USERPROFILE%\yt-sub\watch_new.ps1" >nul
if errorlevel 1 goto fail
copy /y "%USERPROFILE%\yt-sub\watch_new.ps1" "%USERPROFILE%\yt-sub\watch.ps1" >nul
findstr /c:"done2" "%USERPROFILE%\yt-sub\watch.ps1" >nul
if errorlevel 1 goto fail
echo.
echo ==== NEW VERSION OK  (성공! 창을 닫아도 돼요) ====
pause
exit /b
:fail
echo.
echo ==== 실패: 이 창을 찍어서 보내 주세요 ====
pause
