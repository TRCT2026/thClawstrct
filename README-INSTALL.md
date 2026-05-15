# ติดตั้ง thClaws บน Windows

> **thClaws รันบน Docker ไม่ได้** เพราะเป็น native desktop app (Rust + Tauri)
> ไม่มี Dockerfile ใน repo และ Tauri GUI ทำงานใน container ไม่ได้

---

## ข้อมูลเกี่ยวกับ thClaws

- **คืออะไร:** Open-source AI agent harness platform — runs on your own machine
- **เทคโนโลยี:** Rust 88% + TypeScript 11% + Tauri (เหมือน VS Code แต่เบากว่า)
- **Repo:** https://github.com/thClaws/thClaws
- **เว็บ:** https://thclaws.ai
- **License:** Apache-2.0 / MIT

---

## ทางเลือกการติดตั้ง (เลือก 1)

### A. Pre-built Installer (เร็วสุด — 2 นาที)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install-thclaws.ps1
```

Script จะ:
1. ตรวจสถาปัตยกรรม CPU (ARM64 / x86_64)
2. โหลด `.msi` ที่ตรง arch จาก GitHub Releases
3. รัน installer

**ข้อจำกัด:** v0.9.6 มี installer แค่ ARM64 — ถ้า PC คุณเป็น x86_64 ต้องไปทาง B

### B. Build from Source (รับประกันได้ทุก arch — 15-30 นาที)

ติดตั้ง prerequisite ก่อน (ครั้งเดียว):
```powershell
winget install --id Git.Git -e
winget install --id Rustlang.Rustup -e
winget install --id OpenJS.NodeJS.LTS -e
# ปิด/เปิด PowerShell ใหม่
npm install -g pnpm
```

แล้ว build:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\build-thclaws-from-source.ps1
```

Script จะ clone → build frontend → build Rust binary → สร้าง Start Menu shortcut

### C. Official Download (ถ้า A/B ไม่เวิร์ค)

ไปที่ https://thclaws.ai หรือ https://github.com/thClaws/thClaws/releases — โหลดด้วยมือ

---

## เช็คสถาปัตยกรรม CPU ก่อน

ดับเบิลคลิก [check-arch.bat](computer://C:\thClaws\check-arch.bat) → จะบอกว่าคุณเป็น AMD64 (x86_64) หรือ ARM64

---

## หลังติดตั้งเสร็จ

1. เปิด thClaws จาก Start Menu
2. ครั้งแรกจะถามว่าจะเก็บ secrets แบบไหน — เลือก **OS keychain** (Windows Credential Manager)
3. ตั้ง AI provider: ในแชทพิมพ์ `/provider anthropic` แล้ว `/model claude-sonnet-4-6`
4. (Optional) วาง `AGENTS.md` หรือ `CLAUDE.md` ใน project folder — thClaws จะ inject เป็น system prompt อัตโนมัติ

---

## เรื่อง n8n stack ที่ผมทำไปก่อนหน้า

ไฟล์ใน `01-ai-systems\n8n\` **ไม่เกี่ยวข้องกับ thClaws** ผมเข้าใจผิดในตอนแรก
- ถ้าไม่ใช้ → ลบทั้งโฟลเดอร์ได้
- ถ้าอยากใช้ n8n ควบไปด้วย → เก็บไว้ (เป็น automation tool คนละแบบ ใช้ร่วมกับ thClaws ได้)
