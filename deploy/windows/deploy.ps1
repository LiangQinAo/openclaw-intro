param(
  [string]$AppDir = "C:\apps\openclaw-intro",
  [string]$ZipPath = "C:\apps\openclaw-intro\release.zip",
  [string]$Port = "3000"
)

$ErrorActionPreference = "Stop"

Write-Host "[deploy] AppDir=$AppDir"

if (!(Test-Path $AppDir)) {
  New-Item -ItemType Directory -Path $AppDir | Out-Null
}

# Extract release
Write-Host "[deploy] Extracting $ZipPath ..."
Expand-Archive -Force -Path $ZipPath -DestinationPath $AppDir

# Install backend dependencies (requires Node.js on Windows)
$backend = Join-Path $AppDir "backend"
if (!(Test-Path $backend)) {
  throw "backend dir not found: $backend"
}

Write-Host "[deploy] Installing backend deps ..."
Push-Location $backend

# Set proxy if you need it on server side (optional)
# $env:http_proxy = "http://127.0.0.1:10809"
# $env:https_proxy = "http://127.0.0.1:10809"

npm ci --omit=dev
Pop-Location

# (Optional) Run as a Windows service via NSSM if installed.
# If NSSM not available, just prints how to run.
$nssm = "C:\nssm\nssm.exe"
$svc = "openclaw-intro"

if (Test-Path $nssm) {
  Write-Host "[deploy] NSSM detected. Installing/updating service..."
  & $nssm stop $svc | Out-Null 2>$null
  & $nssm remove $svc confirm | Out-Null 2>$null

  $node = (Get-Command node).Source
  $script = Join-Path $backend "server.js"

  & $nssm install $svc $node $script | Out-Null
  & $nssm set $svc AppDirectory $backend | Out-Null
  & $nssm set $svc AppEnvironmentExtra "PORT=$Port" | Out-Null
  & $nssm start $svc | Out-Null

  Write-Host "[deploy] Service started: $svc (PORT=$Port)"
} else {
  Write-Host "[deploy] NSSM not found. To run manually:"
  Write-Host "  cd $backend"
  Write-Host "  set PORT=$Port"
  Write-Host "  node server.js"
}
