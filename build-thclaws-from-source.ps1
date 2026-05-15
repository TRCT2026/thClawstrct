# ============================================================
# thClaws — Build from Source (Windows)
# สำหรับเครื่องที่ไม่มี prebuilt installer (เช่น Windows x86_64)
#
# ใช้เวลา: 15-30 นาที (ครั้งแรก)
# Disk: ~5 GB
#
# วิธีใช้:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\build-thclaws-from-source.ps1
# ============================================================

$ErrorActionPreference = "Stop"

function Test-Command($name) {
    $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host ""
Write-Host "==== Prerequisite Check ====" -ForegroundColor Cyan

$needInstall = @()
if (-not (Test-Command git))   { $needInstall += "Git" }
if (-not (Test-Command cargo)) { $needInstall += "Rust (cargo)" }
if (-not (Test-Command node))  { $needInstall += "Node.js 20+" }
if (-not (Test-Command pnpm))  { $needInstall += "pnpm" }
if (-not (Test-Command link.exe)) {
    $needInstall += "MSVC Build Tools (link.exe) — Visual Studio 2022 Build Tools + C++ workload"
}

if ($needInstall.Count -gt 0) {
    Write-Host ""
    Write-Host "ยังขาด: $($needInstall -join ', ')" -ForegroundColor Red
    Write-Host ""
    Write-Host "ติดตั้งทั้งหมดด้วย winget (copy-paste):" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  winget install --id Git.Git -e" -ForegroundColor White
    Write-Host "  winget install --id Rustlang.Rustup -e" -ForegroundColor White
    Write-Host "  winget install --id OpenJS.NodeJS.LTS -e" -ForegroundColor White
    Write-Host "  # ----- MSVC Build Tools (จำเป็นสำหรับ Rust บน Windows) -----" -ForegroundColor White
    Write-Host "  winget install --id Microsoft.VisualStudio.2022.BuildTools -e --override `"--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --includeRecommended`"" -ForegroundColor White
    Write-Host "  npm install -g pnpm" -ForegroundColor White
    Write-Host ""
    Write-Host "หลังติดตั้ง → ปิด/เปิด PowerShell ใหม่ → รัน script นี้อีกครั้ง" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Git    : $(git --version)" -ForegroundColor Green
Write-Host "[OK] Cargo  : $(cargo --version)" -ForegroundColor Green
Write-Host "[OK] Node   : $(node --version)" -ForegroundColor Green
Write-Host "[OK] pnpm   : $(pnpm --version)" -ForegroundColor Green

# --- Clone or pull ---
$srcDir = "$env:USERPROFILE\source\thClaws"
$parent = Split-Path $srcDir -Parent
if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

if (Test-Path "$srcDir\.git") {
    Write-Host ""
    Write-Host "==== Pulling latest ====" -ForegroundColor Cyan
    Set-Location $srcDir
    git pull
} else {
    Write-Host ""
    Write-Host "==== Cloning thClaws ====" -ForegroundColor Cyan
    git clone https://github.com/thClaws/thClaws.git $srcDir
    Set-Location $srcDir
}

# --- Build frontend ---
Write-Host ""
Write-Host "==== Building frontend (pnpm) ====" -ForegroundColor Cyan
Set-Location "$srcDir\frontend"
pnpm install
pnpm build
Set-Location $srcDir

# --- Build Rust binary ---
Write-Host ""
Write-Host "==== Building Rust binary (cargo) — ใช้เวลานานครั้งแรก ====" -ForegroundColor Cyan
cargo build --release --features gui --bin thclaws

# --- Done ---
$binary = "$srcDir\target\release\thclaws.exe"
if (Test-Path $binary) {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "  Build success!" -ForegroundColor Green
    Write-Host "  Binary: $binary" -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "รัน GUI: " -NoNewline; Write-Host "& '$binary'" -ForegroundColor White
    Write-Host "รัน CLI: " -NoNewline; Write-Host "& '$binary' --cli" -ForegroundColor White
    Write-Host ""

    # Add Start Menu shortcut
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\thClaws.lnk"
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $binary
    $shortcut.WorkingDirectory = (Split-Path $binary)
    $shortcut.Save()
    Write-Host "เพิ่ม Start Menu shortcut แล้ว" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Build failed — ไม่พบ binary ที่ $binary" -ForegroundColor Red
    exit 1
}
