@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Profiles you want active while resolving properties (adjust if needed)
set "MVN_PROFILES=default,default-heavy"

echo === Detecting required Java version per module (no compilation) ===

for /d %%D in (*) do (
  if exist "%%D\pom.xml" call :check_one "%%D"
)
goto :eof


:eval        rem usage: call :eval VAR "module\pom.xml" "expression"
setlocal
set "OUT="
for /f "usebackq delims=" %%V in (`mvn -q -f "%~2\pom.xml" -P %MVN_PROFILES% help:evaluate -Dexpression=%~3 -DforceStdout`) do (
  set "OUT=%%V"
)
endlocal & set "%~1=%OUT%"
goto :eof


:max         rem usage: call :max VAR NUM1 NUM2
setlocal
set "A=%~2"
set "B=%~3"
if "%A%"=="" (set "A=0")
if "%B%"=="" (set "B=0")
rem strip possible "1.8" -> "8"
for /f "tokens=1,2 delims=." %%x in ("%A%") do set "A=%%x"
for /f "tokens=1,2 delims=." %%x in ("%B%") do set "B=%%x"
set /a M=(A GTR B)*A + (A LEQ B)*B
endlocal & set "%~1=%M%"
goto :eof


:check_one
set "MOD=%~1"
rem Skip aggregator POMs (packaging=pom) to reduce noise
call :eval PKG "%MOD%" project.packaging
if /i "!PKG!"=="pom" (
  echo.
  echo === %%~n1 (aggregator POM) ===
  goto :eof
)

echo.
echo === Checking module: %MOD% ===

rem Try in order: maven.compiler.release, else max(source,target), else java.version
call :eval REL "%MOD%" maven.compiler.release
call :eval SRC "%MOD%" maven.compiler.source
call :eval TGT "%MOD%" maven.compiler.target
call :eval JAV "%MOD%" java.version

set "WHY="
set "REQ="

if not "!REL!"=="" (
  set "REQ=!REL!"
  set "WHY=release"
) else (
  call :max MAXST "!SRC!" "!TGT!"
  if not "!MAXST!"=="0" (
    set "REQ=!MAXST!"
    set "WHY=source/target"
  ) else if not "!JAV!"=="" (
    rem java.version is often like 17 or 1.8
    for /f "tokens=1,2 delims=." %%x in ("!JAV!") do set "REQ=%%x"
    if "!REQ!"=="1" set "REQ=8"
    set "WHY=java.version"
  )
)

if "!REQ!"=="" (
  echo (could not resolve compiler level — maybe profile-disabled or inherits from a parent not in this tree)
) else (
  echo -> required Java: !REQ!  (from !WHY!)
)
goto :eof
