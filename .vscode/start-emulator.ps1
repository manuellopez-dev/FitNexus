param(
    [Parameter(Mandatory = $true)]
    [string]$Avd,
    [Parameter(Mandatory = $true)]
    [int]$Port,
    [int]$TimeoutSeconds = 240
)

$ErrorActionPreference = "Stop"
$sdk = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA "Android\Sdk" } else { $env:ANDROID_SDK_ROOT }
$adb = Join-Path $sdk "platform-tools\adb.exe"
$emulator = Join-Path $sdk "emulator\emulator.exe"
$serial = "emulator-$Port"

function Get-DeviceLine {
    (& $adb devices) | Where-Object { $_ -match "^$serial\s" } | Select-Object -First 1
}

function Get-Serials {
    (& $adb devices) | Where-Object { $_ -match "^emulator-\d+\s" }
}

$line = Get-DeviceLine
if ($line -match "\sdevice$") {
    Write-Host "$serial ya esta conectado y autorizado."
    exit 0
}

if (-not $line) {
    $conflict = Get-Serials | Where-Object { $_ -notmatch "^$serial\s" }
    if ($conflict) {
        Write-Host "Aviso: hay otro emulador activo en un puerto distinto ($($conflict -join ', '))."
    }
    Write-Host "Lanzando AVD '$Avd' en puerto $Port..."
    Start-Process -FilePath $emulator -ArgumentList "-avd", $Avd, "-port", $Port -WindowStyle Minimized
}

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
while ((Get-Date) -lt $deadline) {
    $line = Get-DeviceLine
    if ($line -match "\sdevice$") { break }
    if ($line -match "unauthorized") {
        Write-Warning "Emulador $serial esta UNAUTHORIZED: acepta el dialogo 'Allow USB debugging' en la ventana del emulador y marca 'Always allow'."
    }
    Start-Sleep -Seconds 3
}

$line = Get-DeviceLine
if ($line -notmatch "\sdevice$") {
    Write-Error "Timeout: $serial no llego al estado 'device'. Si hay un dialogo abierto en el emulador, aceptalo y vuelve a lanzar (F5)."
    exit 1
}

$bootDeadline = (Get-Date).AddSeconds(60)
while ((Get-Date) -lt $bootDeadline) {
    $boot = (& $adb -s $serial shell getprop sys.boot_completed 2>$null)
    if ("$boot".Trim() -eq "1") { break }
    Start-Sleep -Seconds 3
}

Write-Host "$serial listo."
exit 0
