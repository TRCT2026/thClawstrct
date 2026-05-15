# 01 — AI Systems

โฟลเดอร์สำหรับ AI Automation, Workflow, Bots

## โครงสร้าง
- `workflows/` — n8n / Make / Zapier export (.json)
- `scripts/` — Python / Node scripts (ETL, scraping, API)
- `n8n/` — Self-host configs (docker-compose.yml, .env.example)
- `docs/` — Architecture diagrams, API specs, ADRs

## Stack แนะนำ
- **Automation**: n8n (self-host on VPS) — free, no vendor lock-in
- **LLM**: Claude API / OpenAI / Local (Ollama)
- **Storage**: Supabase / PostgreSQL
- **Deploy**: Docker + Caddy (auto-HTTPS)
