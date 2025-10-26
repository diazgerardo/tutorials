@echo off
setlocal

rem Use mvnw if present
set "MVN=mvn"
if exist "%CD%\mvnw.cmd" set "MVN=%CD%\mvnw.cmd"

echo Warming local repo by visiting every pom.xml under:
echo %CD%
echo.

for /r "%CD%" %%F in (pom.xml) do (
  echo [GO-OFFLINE] %%F
  "%MVN%" -q -f "%%F" -U -C -DskipTests dependency:go-offline
)

echo Done.
endlocal
