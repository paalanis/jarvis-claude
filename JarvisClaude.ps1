# === JARVIS CLAUDE LAUNCHER v2 ===
# Detecta la hora del sistema y reproduce un saludo apropiado
# Abre la app de escritorio de Claude

$rutaBase = "C:\Jarvis\Saludos"
$hora = (Get-Date).Hour

# Determinar la carpeta segun la hora
if ($hora -ge 5 -and $hora -lt 12) {
    $carpeta = "morning"
} elseif ($hora -ge 12 -and $hora -lt 19) {
    $carpeta = "afternoon"
} elseif ($hora -ge 19 -and $hora -lt 23) {
    $carpeta = "evening"
} else {
    $carpeta = "night"
}

# 30% de probabilidad de usar un saludo general en su lugar
if ((Get-Random -Minimum 1 -Maximum 11) -le 3) {
    $rutaGeneral = Join-Path $rutaBase "general"
    if (Test-Path $rutaGeneral) {
        $archivosGeneral = Get-ChildItem -Path $rutaGeneral -Filter *.mp3 -ErrorAction SilentlyContinue
        if ($archivosGeneral.Count -gt 0) {
            $carpeta = "general"
        }
    }
}

$rutaFinal = Join-Path $rutaBase $carpeta

# Seleccionar archivo aleatorio
$archivos = Get-ChildItem -Path $rutaFinal -Filter *.mp3 -ErrorAction SilentlyContinue

if ($archivos.Count -eq 0) {
    # Fallback: si la carpeta esta vacia, busca en cualquier subcarpeta
    $archivos = Get-ChildItem -Path $rutaBase -Filter *.mp3 -Recurse
}

if ($archivos.Count -gt 0) {
    $elegido = $archivos | Get-Random
    
    # === PRE-CARGA DEL AUDIO ===
    Add-Type -AssemblyName presentationCore
    $reproductor = New-Object System.Windows.Media.MediaPlayer
    $reproductor.Open([System.Uri]::new($elegido.FullName))
    $reproductor.Volume = 0.8
    
    # Esperar a que el reproductor cargue completamente el archivo
    $tiempoEspera = 0
    while ($reproductor.NaturalDuration.HasTimeSpan -eq $false -and $tiempoEspera -lt 30) {
        Start-Sleep -Milliseconds 100
        $tiempoEspera++
    }
    
    # Pausa adicional de seguridad para que el sistema de audio este listo
    #Start-Sleep -Milliseconds 400
    
    # === ABRIR LA APP DE ESCRITORIO DE CLAUDE ===
    Start-Process "shell:AppsFolder\Claude_pzs8sxrjxfjjc!Claude"

    # Pequeno delay antes de abrir Claude para no robar el foco al audio
    Start-Sleep -Milliseconds 1000

    # === REPRODUCIR ===
    $reproductor.Play()

    # Esperar a que termine el audio
    Start-Sleep -Seconds 12
    $reproductor.Stop()
    $reproductor.Close()
}
