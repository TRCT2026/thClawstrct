@echo off
REM ============================================
REM n8n One-Click Installer
REM ดับเบิลคลิกไฟล์นี้เพื่อติดตั้ง + รัน n8n
REM ============================================

cd /d "%~dp0"

echo.
echo ==========================================
echo   n8n Local Stack - Installer
echo ==========================================
echo.

REM ตรวจว่า Docker Desktop รันอยู่ไหม
docker version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Desktop ไม่ได้รันอยู่
    echo.
    echo วิธีแก้:
    echo   1. เปิด Docker Desktop จาก Start Menu
    echo   2. รอจนสถานะเป็น "Engine running" ที่มุมซ้ายล่าง
    echo   3. ดับเบิลคลิกไฟล์นี้อีกครั้ง
    echo.
    pause
    exit /b 1
)

echo [OK] Docker is running
echo.
echo Starting installation... (ครั้งแรกใช้เวลา 2-5 นาที)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-local.ps1"

if errorlevel 1 (
    echo.
    echo [ERROR] การติดตั้งล้มเหลว ดู error ข้างบน
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   เปิดเบราว์เซอร์ที่: http://localhost:5678
echo ==========================================
echo.

REM เปิดเบราว์เซอร์อัตโนมัติหลังรอ 5 วินาที
timeout /t 5 /nobreak >nul
start http://localhost:5678

echo.
echo (หน้าต่างนี้กดปุ่มอะไรก็ได้เพื่อปิด)
pause >nul
