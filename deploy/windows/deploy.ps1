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
npm ci --omit=dev
Pop-Location

# Try to keep the service running
$nssm = "C:\nssm\nssm.exe"
$svc = "openclaw-intro"
$pidFile = Join-Path $AppDir "run.pid"

# Ensure firewall rule exists (best-effort)
try {
  Write-Host "[deploy] Ensuring firewall rule for TCP $Port ..."
  netsh advfirewall firewall add rule name="openclaw-intro-$Port" dir=in action=allow protocol=TCP localport=$Port | Out-Null
} catch {
  Write-Host "[deploy] Firewall rule skipped: $($_.Exception.Message)"
}

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
  exit 0
}

# Fallback: run as a background process (will not survive reboot)
Write-Host "[deploy] NSSM not found. Starting node as background process (non-persistent) ..."

# Stop previous instance if pid file exists
if (Test-Path $pidFile) {
  try {
    $oldPid = Get-Content $pidFile | Select-Object -First 1
    if ($oldPid) {
      $p = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
      if ($p) {
        Write-Host "[deploy] Stopping previous process PID=$oldPid"
        Stop-Process -Id $oldPid -Force
      }
    }
  } catch {
    Write-Host "[deploy] Could not stop old process: $($_.Exception.Message)"
  }
}

$env:PORT = $Port
$proc = Start-Process -FilePath (Get-Command node).Source -ArgumentList "server.js" -WorkingDirectory $backend -PassThru -WindowStyle Hidden

Set-Content -Path $pidFile -Value $proc.Id
Write-Host "[deploy] Started PID=$($proc.Id) on PORT=$Port"
