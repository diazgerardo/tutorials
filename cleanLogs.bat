@echo off
echo Scanning and deleting all .log files recursively...
echo.

rem Change to the directory this script is run from (optional)
cd /d %~dp0

rem Find and delete all .log files recursively
for /r %%f in (*.log) do (
    echo Deleting: "%%f"
    del /f /q "%%f"
)

echo.
echo Done deleting .log files.
pause
