# Builds the throwaway prototype and its unsigned per-user NSIS installer.
# Usage: powershell -ExecutionPolicy Bypass -File prototype/toast-buttons/build.ps1
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (Test-Path out) { Remove-Item -Recurse -Force out }
& dotnet publish ToastSpike.csproj -c Release -o out/publish
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed ($LASTEXITCODE)" }
& "${env:ProgramFiles(x86)}\NSIS\makensis.exe" /V2 installer.nsi
if ($LASTEXITCODE -ne 0) { throw "makensis failed ($LASTEXITCODE)" }
Get-Item out/ToastSpikeSetup.exe | Select-Object FullName, Length
