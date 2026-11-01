[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [switch]$Stop
)

$ErrorActionPreference = 'Continue'
$PSNativeCommandUseErrorActionPreference = $false
$root = $PSScriptRoot
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$emulator = Join-Path $sdk 'emulator\emulator.exe'
$runDir = Join-Path $root 'build\run'

$targets = [ordered]@{
    mobile = 'lib/main.dart'
    wear   = 'lib/main_wear.dart'
    tv     = 'lib/main_tv.dart'
}

function Get-AdbDevices {
    (& $adb devices) | ForEach-Object {
        if ($_ -match '^(\S+)\s+(device|unauthorized|offline)$') {
            [pscustomobject]@{ Serial = $Matches[1]; State = $Matches[2] }
        }
    }
}

function Get-AvdName([string]$serial) {
    $name = (& $adb -s $serial emu avd name 2>$null | Select-Object -First 1)
    return "$name".Trim()
}

function Wait-DeviceReady([string]$serial, [int]$timeoutSec = 300) {
    $until = (Get-Date).AddSeconds($timeoutSec)
    $warned = $false
    while ((Get-Date) -lt $until) {
        $d = Get-AdbDevices | Where-Object { $_.Serial -eq $serial }
        if ($d -and $d.State -eq 'device') {
            $boot = (& $adb -s $serial shell getprop sys.boot_completed 2>$null) -join ''
            if ("$boot".Trim() -eq '1') { return $true }
        }
        elseif ($d -and $d.State -eq 'unauthorized' -and -not $warned) {
            Write-Host ">> $serial esta 'unauthorized': acepta 'Allow USB debugging' en la ventana del emulador."
            $warned = $true
        }
        Start-Sleep -Seconds 3
    }
    return $false
}

function Ensure-Emulator([string]$avd, [int]$port) {
    $want = "emulator-$port"
    $existing = @(Get-AdbDevices | Where-Object { $_.Serial -like 'emulator-*' })
    foreach ($e in $existing) {
        if ($e.Serial -eq $want -or (Get-AvdName $e.Serial) -eq $avd) {
            Write-Host ">> Emulador $avd ya corriendo en $($e.Serial)"
            if (-not (Wait-DeviceReady $e.Serial)) { throw "El emulador $avd no llego al estado 'device'." }
            return $e.Serial
        }
    }
    New-Item -ItemType Directory -Force -Path $runDir | Out-Null
    Write-Host ">> Lanzando emulador $avd (puerto $port)..."
    Start-Process -FilePath $emulator `
        -ArgumentList @('-avd', $avd, '-port', $port, '-no-boot-anim') `
        -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $runDir "emulator-$port.log") `
        -RedirectStandardError (Join-Path $runDir "emulator-$port.err.log")
    if (-not (Wait-DeviceReady $want)) { throw "El emulador $avd ($want) no llego al estado 'device' en 300s." }
    return $want
}

if ($Stop) {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
        Where-Object { $_.CommandLine -like '*flutter run*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    foreach ($e in (Get-AdbDevices | Where-Object { $_.Serial -like 'emulator-*' })) {
        $n = Get-AvdName $e.Serial
        if ($n -like 'Television*' -or $n -like 'Wear*') {
            & $adb -s $e.Serial emu kill 2>$null
            Write-Host ">> Emulador $n detenido."
        }
    }
    Write-Host '>> flutter run cerrado y emuladores detenidos.'
    return
}

Write-Host '== FitNexus: movil + watch + TV =='

$phone = Get-AdbDevices |
    Where-Object { $_.Serial -notlike 'emulator-*' -and $_.State -eq 'device' } |
    Select-Object -First 1
if (-not $phone) { throw 'No hay telefono conectado. Conecta el movil con depuracion USB activa.' }

$wearSerial = Ensure-Emulator 'Wear_OS_XL_Round' 5556
$tvSerial = Ensure-Emulator 'Television_4K' 5554

if (-not $SkipBuild) {
    New-Item -ItemType Directory -Force -Path $runDir | Out-Null
    foreach ($k in $targets.Keys) {
        Write-Host ">> Build $k ($($targets[$k]))..."
        Push-Location $root
        try {
            flutter build apk --debug -t $targets[$k]
            if ($LASTEXITCODE -ne 0) { throw "Fallo el build de $k" }
        }
        finally { Pop-Location }
        Copy-Item (Join-Path $root 'build\app\outputs\flutter-apk\app-debug.apk') `
            (Join-Path $runDir "$k.apk") -Force
    }
}

$runs = @(
    @{ Name = 'Movil'; Serial = $phone.Serial; Target = $targets['mobile']; Apk = (Join-Path $runDir 'mobile.apk') },
    @{ Name = 'Watch'; Serial = $wearSerial; Target = $targets['wear']; Apk = (Join-Path $runDir 'wear.apk') },
    @{ Name = 'TV';    Serial = $tvSerial; Target = $targets['tv']; Apk = (Join-Path $runDir 'tv.apk') }
)

foreach ($r in $runs) {
    if (-not (Test-Path $r.Apk)) { throw "Falta $($r.Apk). Ejecuta sin -SkipBuild." }
    $cmd = "Set-Location -LiteralPath '$root'; flutter run -d '$($r.Serial)' -t '$($r.Target)' --use-application-binary='$($r.Apk)'"
    Start-Process powershell.exe -ArgumentList @('-NoLogo', '-NoExit', '-Command', $cmd)
    Write-Host ">> [$($r.Name)] flutter run abierto en $($r.Serial)"
    Start-Sleep -Seconds 3
}

Write-Host ''
Write-Host 'Listo: 3 ventanas de flutter run (una por dispositivo).'
Write-Host '  En cada ventana: r = hot reload, R = hot restart, q = cerrar'
Write-Host '  Para todo:       .\run_all.ps1 -Stop'
