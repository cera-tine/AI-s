<#
.SYNOPSIS
    Mencatat sesi kerja ke log harian, lalu commit dan push ke GitHub.

.DESCRIPTION
    Skrip ini melakukan tiga hal:
      1. Menambahkan satu baris catatan ke log/YYYY-MM-DD.md
      2. Melakukan git add + commit
      3. Melakukan git push ke origin

    Jalankan dari mana saja; skrip otomatis berpindah ke folder repo.

.PARAMETER Pesan
    Deskripsi singkat pekerjaan. Jika kosong, dipakai pesan bawaan.

.PARAMETER Alat
    Alat yang dipakai: zcode, opencode, antigravity, atau lain.

.PARAMETER TanpaPush
    Lakukan commit saja, tanpa push.

.EXAMPLE
    .\catat.ps1 "menyelesaikan latihan sorting"

.EXAMPLE
    .\catat.ps1 -Alat antigravity "memperbaiki bug render"

.EXAMPLE
    .\catat.ps1 -TanpaPush "catatan lokal saja"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $Pesan,

    [ValidateSet('zcode', 'opencode', 'antigravity', 'lain')]
    [string] $Alat = 'lain',

    [switch] $TanpaPush
)

$ErrorActionPreference = 'Stop'

# --- Pastikan git & gh tersedia (PATH mesin + user) ---
$machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath    = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path    = "$machinePath;$userPath;$env:Path"

# --- Berpindah ke root repo (lokasi skrip ini) ---
$repoRoot = $PSScriptRoot
Set-Location $repoRoot

if (-not (Test-Path (Join-Path $repoRoot '.git'))) {
    Write-Error "Folder ini bukan repositori git: $repoRoot"
    exit 1
}

# --- Susun pesan ---
$teks = if ($Pesan -and $Pesan.Count -gt 0) { ($Pesan -join ' ').Trim() } else { 'sesi kerja' }
if ([string]::IsNullOrWhiteSpace($teks)) { $teks = 'sesi kerja' }

$sekarang = Get-Date
$tanggal  = $sekarang.ToString('yyyy-MM-dd')
$jam      = $sekarang.ToString('HH:mm')

$labelAlat = switch ($Alat) {
    'zcode'       { 'ZCode' }
    'opencode'    { 'opencode' }
    'antigravity' { 'Antigravity' }
    default       { 'lain' }
}

# --- Tulis ke log harian ---
$logDir = Join-Path $repoRoot 'log'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

$logFile = Join-Path $logDir "$tanggal.md"
if (-not (Test-Path $logFile)) {
    $judul = "# Log $tanggal"
    Set-Content -Path $logFile -Value $judul -Encoding utf8
    Add-Content -Path $logFile -Value '' -Encoding utf8
}

$baris = "- ``$jam`` **$labelAlat** — $teks"
Add-Content -Path $logFile -Value $baris -Encoding utf8

Write-Host "  tercatat: $baris" -ForegroundColor DarkGray

# --- Commit ---
git add -A
if ($LASTEXITCODE -ne 0) { Write-Error 'git add gagal'; exit 1 }

# Tidak ada perubahan -> tetap catat bahwa sesi terjadi (log sudah berubah, jadi ini jarang)
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host '  tidak ada perubahan untuk di-commit.' -ForegroundColor Yellow
    exit 0
}

$commitMsg = "[$labelAlat] $teks"
git commit --quiet -m $commitMsg
if ($LASTEXITCODE -ne 0) { Write-Error 'git commit gagal'; exit 1 }

$sha = (git rev-parse --short HEAD).Trim()
Write-Host "  commit : $sha" -ForegroundColor Green

# --- Push ---
if ($TanpaPush) {
    Write-Host '  push   : dilewati (-TanpaPush)' -ForegroundColor Yellow
    exit 0
}

# Branch saat ini; buat branch main bila repo masih kosong
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
git push --quiet -u origin $branch 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "  push   : OK ke origin/$branch" -ForegroundColor Green
} else {
    Write-Warning "push gagal. Periksa koneksi atau jalankan: gh auth status"
    exit 1
}
