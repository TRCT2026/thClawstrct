# =============================================
# n8n Local Stack - One-click starter (Windows)
# วิธีใช้: เปิด PowerShell ในโฟลเดอร์นี้ แล้วรัน:
#   .\start-local.ps1
# =============================================

$ErrorActionPreference = "Stop"

Write-Host "==> n8n Local Setup" -ForegroundColor Cyan

# 1) ตรวจ Docker
Write-Host "[1/4] Checking Docker..."
try {
    docker version | Out-Null
} catch {
    Write-Host "ERROR: Docker Desktop ไม่ได้รัน — เปิด Docker Desktop ก่อนแล้วลองใหม่" -ForegroundColor Red
    exit 1
}

# 2) สร้าง .env ถ้ายังไม่มี
if (-not (Test-Path ".env")) {
    Write-Host "[2/4] Generating .env with random secrets..."

    function New-RandomHex($bytes = 32) {
        $b = New-Object byte[] $bytes
        [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
        ($b | ForEach-Object { $_.ToString("x2") }) -join ""
    }

    $pgPwd = New-RandomHex 16
    $encKey = New-RandomHex 32
    $jwt = New-RandomHex 32

    @"
# Auto-generated local secrets ($(Get-Date -Format "yyyy-MM-dd HH:mm"))
N8N_HOST=localhost
ACME_EMAIL=local@dev.local
POSTGRES_USER=n8n
POSTGRES_DB=n8n
POSTGRES_PASSWORD=$pgPwd
N8N_ENCRYPTION_KEY=$encKey
N8N_JWT_SECRET=$jwt
"@ | Out-File -Encoding ASCII -FilePath ".env"

    Write-Host "    .env created" -ForegroundColor Green
} else {
    Write-Host "[2/4] .env exists — skip"
}

# 3) สร้างโฟลเดอร์ files
if (-not (Test-Path "files")) {
    New-Item -ItemType Directory -Path "files" | Out-Null
}

# 4) Start stack
Write-Host "[3/4] Pulling images (ใช้เวลาครั้งแรก ~2-5 นาที)..."
docker compose -f docker-compose.local.yml pull

Write-Host "[4/4] Starting stack..."
docker compose -f docker-compose.local.yml up -d

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " n8n is starting!" -ForegroundColor Green
Write-Host " URL:  http://localhost:5678" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Status:"
docker compose -f docker-compose.local.yml ps

Write-Host ""
Write-Host "ดู log สด ๆ:" -ForegroundColor Cyan
Write-Host "  docker compose -f docker-compose.local.yml logs -f n8n"
Write-Host ""
Write-Host "หยุด stack:" -ForegroundColor Cyan
Write-Host "  docker compose -f docker-compose.local.yml down"
