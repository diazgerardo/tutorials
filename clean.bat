@echo off
setlocal

rem --- Resolve local repo path ---
set "M2_DEFAULT=%USERPROFILE%\.m2\repository"
set "M2=%~1"

if not defined M2 (
  set "SETTINGS=%USERPROFILE%\.m2\settings.xml"
  if exist "%SETTINGS%" (
    for /f "tokens=2 delims=<>" %%A in ('findstr /i "<localRepository>" "%SETTINGS%"') do set "M2=%%A"
  )
)

if not defined M2 set "M2=%M2_DEFAULT%"

echo Using local repo: "%M2%"
if not exist "%M2%" (
  echo Repo not found: "%M2%"
  echo Usage: clean-m2-corruption.bat  [optional-path-to-repo]
  exit /b 1
)

rem --- 1) Remove failed/partial download markers (.lastUpdated) ---
for /r "%M2%" %%F in (*.lastUpdated) do (
  del /q "%%F" 2>nul
)

rem --- 2) Detect POMs that are actually HTML and delete their version folder ---
for /f "delims=" %%F in ('
  findstr /m /s /i /c:"<!DOCTYPE html>" /c:"<html" "%M2%\*.pom" 2^>nul
') do (
  echo CORRUPTED: "%%F"
  rmdir /s /q "%%~dpF"
)

echo Done.
endlocal
