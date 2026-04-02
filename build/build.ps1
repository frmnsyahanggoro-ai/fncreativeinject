# Powered by FN CREATIVE — Windows build (ZIP akar modul = siap Magisk)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Out = Join-Path $Root "FN-CREATIVE-AutoProps-v25-Final.zip"
$ModuleDir = Join-Path $Root "module"
$GuiDir = Join-Path $Root "gui"

Write-Host "Building FN CREATIVE module..."

$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { $py = Get-Command python3 -ErrorAction SilentlyContinue }
if ($py) {
    Push-Location $Root
    try {
        & $py.Name tools/build_banner.py
    } catch {}
    Pop-Location
}

if (Test-Path -LiteralPath $GuiDir) {
    $destGui = Join-Path $ModuleDir "gui"
    New-Item -ItemType Directory -Path $destGui -Force | Out-Null
    Get-ChildItem -LiteralPath $GuiDir -File -Force | ForEach-Object {
        if ($_.Name -match '^(README\.txt|\.gitkeep)$') { return }
        if ($_.Extension -eq '.md') { return }
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $destGui $_.Name) -Force
    }
}

if (Test-Path $Out) { Remove-Item -Force $Out }

$stage = Join-Path ([IO.Path]::GetTempPath()) ("fnprops_" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $stage | Out-Null
try {
    Get-ChildItem -LiteralPath $ModuleDir -Force | ForEach-Object {
        if ($_.Name -eq "branding") { return }
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $stage $_.Name) -Recurse -Force
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $Out, [System.IO.Compression.CompressionLevel]::Optimal, $false)
} finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Build finished"
Write-Host $Out
