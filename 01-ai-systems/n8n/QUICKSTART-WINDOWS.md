# Quick Start — Windows + Docker Desktop

ติดตั้ง n8n บนเครื่องตัวเองใน **3 ขั้นตอน** — ไม่ต้องมีโดเมน, ไม่ต้องเช่า VPS

## ก่อนเริ่ม
- [x] Docker Desktop ติดตั้งแล้วและเปิดอยู่ (Engine running)
- [x] WSL2 enabled (Docker Desktop จะแจ้งเตือนถ้ายังไม่เปิด)

---

## STEP 1 — เปิด PowerShell ในโฟลเดอร์ n8n

วิธีง่ายสุด: เปิด File Explorer → ไปที่ `C:\thClaws\01-ai-systems\n8n\` → คลิกขวาในโฟลเดอร์ → **"Open in Terminal"**

หรือพิมพ์ใน PowerShell:
```powershell
cd C:\thClaws\01-ai-systems\n8n
```

---

## STEP 2 — รันสคริปต์ติดตั้ง

```powershell
# ถ้า PowerShell บล็อก script ให้อนุญาตก่อน (รันครั้งเดียวพอ)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Start!
.\start-local.ps1
```

สคริปต์จะ:
1. ตรวจว่า Docker รันอยู่
2. สร้าง `.env` พร้อม secrets แบบสุ่ม
3. Pull image (postgres + n8n) — ครั้งแรก ~2-5 นาที
4. Start stack

---

## STEP 3 — เปิดเบราว์เซอร์

http://localhost:5678

ตั้ง owner account → เริ่มสร้าง workflow ได้เลย

---

## เช็คใน Docker Desktop

หลังรันแล้วใน Containers tab จะเห็น 2 ตัว:
- `n8n-local-n8n-1` → port 5678
- `n8n-local-postgres-1`

---

## คำสั่งที่ใช้บ่อย

| ทำอะไร | คำสั่ง |
|--------|--------|
| ดู log | `docker compose -f docker-compose.local.yml logs -f n8n` |
| Restart | `docker compose -f docker-compose.local.yml restart` |
| หยุด (เก็บ data) | `docker compose -f docker-compose.local.yml down` |
| ลบทุกอย่าง (รวม data!) | `docker compose -f docker-compose.local.yml down -v` |
| Update เป็นเวอร์ชันใหม่ | `docker compose -f docker-compose.local.yml pull` แล้ว `up -d` |

---

## ปัญหาที่พบบ่อย

**"docker: command not found"**
→ เปิด Docker Desktop ก่อน รอจนสถานะเป็น "Engine running"

**Port 5678 ถูกใช้แล้ว**
→ แก้ `docker-compose.local.yml` บรรทัด `"5678:5678"` เป็น `"5679:5678"` แล้วเปิด http://localhost:5679

**เข้า localhost:5678 ไม่ติด**
→ รอ ~30 วินาทีหลัง start (n8n ใช้เวลา init DB ครั้งแรก)
→ ดู log: `docker compose -f docker-compose.local.yml logs n8n`

**Webhook ใช้ไม่ได้จากภายนอก**
→ Local mode webhook ใช้ได้แค่จากเครื่องตัวเอง
→ ถ้าต้องการให้ external service เรียก webhook ได้ ใช้ ngrok หรือ deploy บน VPS (ใช้ `docker-compose.yml` + `INSTALL.md`)

---

## ขั้นถัดไป

- ผูก Claude API เป็น credential ใน n8n
- สร้าง workflow แรก (เช่น: Webhook → Claude → Slack)
- พร้อมขึ้น production → ดู `INSTALL.md` สำหรับ deploy บน VPS
