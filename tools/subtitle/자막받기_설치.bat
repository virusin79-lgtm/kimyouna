@echo off
chcp 65001 >nul
title 자막받기 설치
echo.
echo ==== 자막받기 설치 (새 PC용) ====
echo 창을 닫지 말고 끝날 때까지 기다려 주세요.
echo.
echo [1/4] 유튜브 다운로드 프로그램(yt-dlp) 설치
winget install -e --id yt-dlp.yt-dlp --accept-source-agreements --accept-package-agreements
echo.
echo [2/4] 영상 자르기 프로그램(ffmpeg) 설치
winget install -e --id Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
echo.
echo [3/4] 구글 드라이브 앱 설치
winget install -e --id Google.GoogleDrive --accept-source-agreements --accept-package-agreements
echo.
echo ------------------------------------------------------------
echo  구글 드라이브 앱이 열리면 본인 계정으로 로그인해 주세요.
echo  (안 열리면 시작 버튼에서 "Google Drive"를 찾아 실행)
echo  로그인이 끝나고 1분 뒤에 아무 키나 누르세요.
echo ------------------------------------------------------------
start "" "%ProgramFiles%\Google\Drive File Stream\launch.bat" 2>nul
pause
echo.
echo [4/4] 자동 받기 장치 + 바탕화면 아이콘 설치, 첫 실행
powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:Path=[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User'); irm https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/840b7ec4b19d61f511bdad98f6be2a70eb58fe98/tools/subtitle/setup.ps1 | iex; irm https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/840b7ec4b19d61f511bdad98f6be2a70eb58fe98/tools/subtitle/setup_auto.ps1 | iex"
echo.
echo ==== 끝! 초록색 OK 가 보이면 성공이에요. 이 화면을 캡처해서 클로드에게 보내 주세요. ====
pause
