@echo off
chcp 65001 >nul
title 자막받기 업데이트
echo 자막받기 업데이트 중... 끝날 때까지 기다려 주세요.
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/virusin79-lgtm/kimyouna/840b7ec4b19d61f511bdad98f6be2a70eb58fe98/tools/subtitle/setup_auto.ps1 | iex"
echo.
echo ==== 끝! 이 창은 닫아도 돼요. ====
pause
