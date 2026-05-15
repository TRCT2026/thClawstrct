@echo off
echo.
echo === Your Windows Architecture ===
echo.
echo PROCESSOR_ARCHITECTURE = %PROCESSOR_ARCHITECTURE%
echo PROCESSOR_ARCHITEW6432 = %PROCESSOR_ARCHITEW6432%
echo.
if /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo ^>^>^> x86_64 / Intel-AMD 64-bit ^(พบบ่อยที่สุด^)
    echo     thClaws v0.9.6 ไม่มี installer สำหรับ arch นี้ ^(เฉพาะ ARM64^)
    echo     แนะนำ: Build from source ^หรือใช้ release ก่อนหน้า
) else if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    echo ^>^>^> ARM64 ^(Surface Pro X, Snapdragon laptops^)
    echo     ใช้ installer ของ thClaws v0.9.6 ได้เลย
) else (
    echo ^>^>^> Unknown: %PROCESSOR_ARCHITECTURE%
)
echo.
pause
