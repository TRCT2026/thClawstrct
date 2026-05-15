# n8n Stack — Install Guide (Production)

**Stack**: n8n + PostgreSQL 16 + Caddy 2 (auto-HTTPS)
**OS**: Ubuntu 22.04 / 24.04 LTS (อื่นได้ แต่คำสั่งอ้างอิงตามนี้)
**Spec ขั้นต่ำ**: 2 vCPU / 2 GB RAM / 20 GB disk

---

## STEP 0 — เตรียม

1. VPS Ubuntu LTS + public IP
2. Domain ชี้ A record → IP server (รอ DNS propagate ~5 นาที)
3. SSH เข้า server ในชื่อ root หรือ user ที่ sudo ได้

ตรวจ DNS:
```bash
dig +short n8n.yourdomain.com
# ต้องคืน IP ของ server
```

---

## STEP 1 — ติดตั้ง Docker

```bash
# Update + install
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER

# logout/login เพื่อให้ group มีผล (หรือใช้ newgrp docker)
newgrp docker

# ตรวจ
docker --version
docker compose version
```

---

## STEP 2 — Clone stack ไป server

อัปโหลดโฟลเดอร์นี้ทั้งหมดไปที่ `/opt/n8n-stack`:

```bash
# จากเครื่อง local
scp -r ./n8n root@SERVER_IP:/opt/n8n-stack

# หรือถ้าอยู่บน server แล้ว
sudo mkdir -p /opt/n8n-stack
cd /opt/n8n-stack
# (วางไฟล์: docker-compose.yml, Caddyfile, .env.example, backup.sh)
```

---

## STEP 3 — สร้าง `.env`

```bash
cd /opt/n8n-stack
cp .env.example .env

# สร้าง secrets อัตโนมัติ
PG_PWD=$(openssl rand -base64 24 | tr -d '/+=' )
ENC_KEY=$(openssl rand -hex 32)
JWT=$(openssl rand -hex 32)

# แก้ .env (ใช้ sed หรือเปิดด้วย nano)
sed -i "s|CHANGE_ME_STRONG_PASSWORD|$PG_PWD|" .env
sed -i "0,/CHANGE_ME_64_HEX_CHARS/{s|CHANGE_ME_64_HEX_CHARS|$ENC_KEY|}" .env
sed -i "s|CHANGE_ME_64_HEX_CHARS|$JWT|" .env

# แก้ domain + email
nano .env  # แก้ N8N_HOST และ ACME_EMAIL

chmod 600 .env
```

> สำคัญ: เก็บ `.env` ไว้ที่ปลอดภัย — `N8N_ENCRYPTION_KEY` คือ key ถอดรหัส credentials ทั้งหมด

---

## STEP 4 — เปิด firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 443/udp   # HTTP/3
sudo ufw enable
```

---

## STEP 5 — Start stack

```bash
cd /opt/n8n-stack
docker compose up -d

# ดู log สด ๆ
docker compose logs -f

# Caddy จะออก SSL cert ให้อัตโนมัติ — รอ ~30 วินาที
```

ตรวจสถานะ:
```bash
docker compose ps
# ทั้ง 3 container ต้องเป็น "running" และ "healthy"
```

เปิดเบราว์เซอร์ → `https://n8n.yourdomain.com` → ตั้ง owner account

---

## STEP 6 — ตั้ง backup อัตโนมัติ

```bash
chmod +x /opt/n8n-stack/backup.sh

# Cron daily 03:00
sudo crontab -e
# เพิ่มบรรทัด:
0 3 * * * cd /opt/n8n-stack && /opt/n8n-stack/backup.sh >> /var/log/n8n-backup.log 2>&1
```

---

## OPERATIONS

| Action | Command |
|--------|---------|
| Restart | `docker compose restart` |
| Stop | `docker compose down` |
| Update (latest) | `docker compose pull && docker compose up -d` |
| ดู log | `docker compose logs -f n8n` |
| เข้า DB | `docker compose exec postgres psql -U n8n` |
| Backup ทันที | `bash backup.sh` |

---

## TROUBLESHOOTING

**SSL ออกไม่ได้**
- ตรวจ DNS A record ชี้ถูก IP
- เช็ค port 80, 443 เปิด: `sudo ss -tlnp | grep -E ':80|:443'`
- ดู log Caddy: `docker compose logs caddy`

**n8n ขึ้น "tunnel" หรือไม่เห็น webhook URL**
- ตรวจ `N8N_HOST` และ `WEBHOOK_URL` ใน `.env`
- ต้อง `docker compose up -d --force-recreate` หลังแก้ env

**ลืม password**
```bash
docker compose exec n8n n8n user-management:reset
```

**Restore จาก backup**
```bash
# DB
gunzip -c db_YYYYMMDD.sql.gz | docker compose exec -T postgres psql -U n8n n8n

# n8n volume
docker run --rm -v n8n-stack_n8n_data:/data \
  -v /opt/backups/n8n:/backup alpine \
  sh -c "cd /data && tar xzf /backup/n8n_data_YYYYMMDD.tar.gz"
```

---

## SECURITY CHECKLIST

- [x] `.env` มี `chmod 600`
- [x] เปิดเฉพาะ port 22, 80, 443
- [x] ตั้ง SSH key (ปิด password login)
- [x] เก็บ `N8N_ENCRYPTION_KEY` แยกต่างหาก (1Password / Bitwarden)
- [x] เปิด 2FA ใน n8n หลังสมัครเสร็จ
- [x] Backup เก็บนอก server (rsync ไป S3/Backblaze ทุก 7 วัน)
