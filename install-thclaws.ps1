# ============================================================
# thClaws Installer for Windows (Smart, v2)
# - Detects CPU architecture
# - Scans ALL releases (newest first) for matching .msi
# - Falls back to instructions if none found
#
# วิธีใช้:
#   cd C:\thClaws
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\install-thclaws.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  thClaws Installer for Windows" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# --- 1) Detect architecture ---
$arch = $env:PROCESSOR_ARCHITECTURE
Write-Host "[1/4] Detected architecture: $arch" -ForegroundColor Yellow

$pattern = switch ($arch) {
    "ARM64" { "*aarch64-pc-windows*.msi" }
    "AMD64" { "*x86_64-pc-windows*.msi" }
    default { $null }
}

if ($null -eq $pattern) {
    Write-Host "    Unsupported architecture: $arch" -ForegroundColor Red
    exit 1
}

$installDir = "$env:LOCALAPPDATA\thClaws"
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# --- 2) Scan ALL releases (newest first) ---
Write-Host "[2/4] Scanning releases for matching $arch installer..." -ForegroundColor Yellow

$headers = @{ "User-Agent" = "thClaws-Installer" }
$releases = Invoke-RestMethod -Uri "https://api.github.com/repos/thClaws/thClaws/releases?per_page=30" -Headers $headers

$found = $null
foreach ($r in $releases) {
    $asset = $r.assets | Where-Object { $_.name -like $pattern } | Select-Object -First 1
    if ($asset) {
        $found = [PSCustomObject]@{
            Version = $r.tag_name
            Asset   = $asset
        }
        Write-Host "    Found: $($r.tag_name) → $($asset.name)" -ForegroundColor Green
        break
    } else {
        Write-Host "    Skip $($r.tag_name) — no $arch installer" -ForegroundColor DarkGray
    }
}

if ($null -eq $found) {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host "  ไม่พบ $arch installer ใน 30 release ล่าสุด" -ForegroundColor Red
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "ทางเลือก:" -ForegroundColor Yellow
    Write-Host "  1) Build from source — รัน: .\build-thclaws-from-source.ps1"
    Write-Host "  2) เช็คหน้า https://thclaws.ai/downloads (มี installer ตรงนี้หรือไม่)"
    exit 0
}

# --- 3) Download ---
$msiPath = Join-Path $installDir $found.Asset.name
Write-Host "[3/4] Downloading $($found.Asset.name) (~$([math]::Round($found.Asset.size / 1MB, 1)) MB)..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $found.Asset.browser_download_url -OutFile $msiPath -UseBasicParsing
Write-Host "    Saved: $msiPath" -ForegroundColor Green

# --- 4) Install ---
Write-Host "[4/4] Launching installer (UAC popup จะขึ้น)..." -ForegroundColor Yellow
$proc = Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`"" -Wait -PassThru
if ($proc.ExitCode -ne 0) {
    Write-Host "Installer exit code: $($proc.ExitCode)" -ForegroundColor Red
    exit $proc.ExitCode
}

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "  Done! เปิด thClaws จาก Start Menu" -ForegroundColor Green
Write-Host "  Version installed: $($found.Version)" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
