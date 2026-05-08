# === INSTALADOR JARVIS CLAUDE ===
Write-Host "=== INSTALADOR JARVIS CLAUDE ===" -ForegroundColor Cyan
Write-Host ""

$rutaActual = $PSScriptRoot
if (-not (Test-Path "$rutaActual\JarvisClaude.ps1")) {
    Write-Host "❌ Error: ejecute este instalador desde la carpeta del proyecto." -ForegroundColor Red
    Read-Host "Presione Enter para salir"
    return
}

Write-Host "[1/5] Copiando archivos a C:\Jarvis..." -ForegroundColor Yellow
if ((Test-Path "C:\Jarvis") -and ($rutaActual -ne "C:\Jarvis")) {
    $confirmar = Read-Host "C:\Jarvis ya existe. Sobrescribir? (S/N)"
    if ($confirmar -ne "S" -and $confirmar -ne "s") {
        Write-Host "Instalacion cancelada." -ForegroundColor Yellow
        return
    }
    Remove-Item "C:\Jarvis" -Recurse -Force
}
if ($rutaActual -ne "C:\Jarvis") {
    Copy-Item -Path $rutaActual -Destination "C:\Jarvis" -Recurse -Force
    Remove-Item "C:\Jarvis\Instalar.ps1" -ErrorAction SilentlyContinue
}
Write-Host "    ✅ Archivos en su lugar" -ForegroundColor Green

Write-Host "[2/5] Detectando app de Claude..." -ForegroundColor Yellow
$appClaude = Get-StartApps | Where-Object { $_.Name -eq "Claude" } | Select-Object -First 1

if (-not $appClaude) {
    Write-Host "    ⚠️ No se encontro la app de escritorio de Claude." -ForegroundColor Yellow
    Write-Host "    Descarguela desde https://claude.ai/download" -ForegroundColor Yellow
    $usarWeb = Read-Host "    Usar version web por ahora? (S/N)"
    if ($usarWeb -eq "S" -or $usarWeb -eq "s") {
        $comandoApertura = 'Start-Process "https://claude.ai"'
    } else {
        Read-Host "Presione Enter para salir"
        return
    }
} else {
    $appId = $appClaude.AppID
    $comandoApertura = "Start-Process `"shell:AppsFolder\$appId`""
    Write-Host "    ✅ App detectada: $appId" -ForegroundColor Green
}

Write-Host "[3/5] Configurando script..." -ForegroundColor Yellow
$scriptPath = "C:\Jarvis\JarvisClaude.ps1"
$contenido = Get-Content $scriptPath -Raw
$contenido = $contenido -replace 'Start-Process "shell:AppsFolder\\[^"]+"', $comandoApertura
$contenido = $contenido -replace 'Start-Process "https://claude\.ai"', $comandoApertura
Set-Content -Path $scriptPath -Value $contenido -Encoding UTF8
Write-Host "    ✅ Script personalizado" -ForegroundColor Green

Write-Host "[4/5] Creando acceso directo..." -ForegroundColor Yellow
$rutaAcceso = "$env:USERPROFILE\Desktop\Claude.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$acceso = $WshShell.CreateShortcut($rutaAcceso)
$acceso.TargetPath = "powershell.exe"
$acceso.Arguments = '-ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Jarvis\JarvisClaude.ps1"'
$acceso.WorkingDirectory = "C:\Jarvis"
if (Test-Path "C:\Jarvis\jarvis.ico") {
    $acceso.IconLocation = "C:\Jarvis\jarvis.ico"
}
$acceso.Save()
Write-Host "    ✅ Acceso directo creado" -ForegroundColor Green

Write-Host "[5/5] Configurando permisos..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "    ✅ Permisos configurados" -ForegroundColor Green
} catch {
    Write-Host "    ⚠️ No critico" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ INSTALACION COMPLETA" -ForegroundColor Green
Write-Host "════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Pruebe haciendo doble clic en 'Claude' en el escritorio." -ForegroundColor Cyan
Read-Host "Presione Enter para salir"
