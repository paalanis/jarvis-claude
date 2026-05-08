cd C:\Jarvis
Write-Host "=== SUBIENDO CAMBIOS A GITHUB ===" -ForegroundColor Cyan

$cambios = git status --porcelain
if (-not $cambios) {
    Write-Host "✅ No hay cambios para subir." -ForegroundColor Green
    Read-Host "Enter para salir"
    exit
}

Write-Host "`nCambios detectados:" -ForegroundColor Yellow
git status --short

$mensaje = Read-Host "`nMensaje del commit (Enter para usar fecha)"
if ([string]::IsNullOrWhiteSpace($mensaje)) {
    $mensaje = "Update " + (Get-Date -Format "yyyy-MM-dd HH:mm")
}

git add .
git commit -m $mensaje
git push

Write-Host "`n✅ Cambios subidos a GitHub" -ForegroundColor Green
Read-Host "Enter para salir"
