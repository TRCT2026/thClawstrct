# thClaws — Workspace Hub

โฟลเดอร์ทำงานหลักสำหรับ **AI Systems / Trading / Government Planning**
จัดวางให้ Claude (Cowork mode) อ่าน/เขียนไฟล์ได้โดยตรง และผู้ใช้สามารถ Git/Sync ได้ทันที

---

## โครงสร้างโฟลเดอร์

```
C:\thClaws\
├── 01-ai-systems\         # AI workflow, automation, bots
│   ├── workflows\         # n8n / Make / Zapier exports (.json)
│   ├── scripts\           # Python / Node automation scripts
│   ├── n8n\               # n8n self-host configs, docker-compose
│   └── docs\              # Architecture diagrams, API specs
│
├── 02-trading\            # Quantitative trading
│   ├── strategies\        # Strategy logic (.py / .pine / .md)
│   ├── backtests\         # Backtest results, equity curves
│   ├── indicators\        # Custom indicators (Pine, MQL, Py)
│   ├── data\              # Historical price data (CSV/Parquet)
│   └── bots\              # Live trading bots, exchange configs
│
├── 03-government\         # Government planning & budgeting
│   ├── proposals\         # โครงการ / ข้อเสนอ
│   ├── budgets\           # งบประมาณ (xlsx)
│   ├── policies\          # นโยบาย / ระเบียบ
│   └── reports\           # รายงานผล / KPI
│
├── 99-shared\             # Cross-domain resources
│   ├── templates\         # Reusable templates (docx/pptx/xlsx)
│   ├── references\        # PDF references, research papers
│   ├── assets\            # Logos, images, fonts
│   └── archive\           # Old / completed work
│
├── _temp\                 # Scratch space (auto-cleanable)
└── _logs\                 # Run logs, error logs
```

---

## หลักการใช้งาน

1. **Final output** → save ใน `01-*`, `02-*`, `03-*` ตาม domain
2. **Work in progress / draft** → ใช้ `_temp\`
3. **Reusable** (template, asset, doc) → ย้ายไป `99-shared\`
4. **Completed / archived** → ย้ายไป `99-shared\archive\`

### Naming convention
- ใช้ kebab-case: `q4-budget-2026.xlsx`, `btc-trend-strategy.py`
- ติด prefix วันที่เมื่อเป็น snapshot: `2026-05-14_backtest-eurusd.csv`
- โครงการรัฐ: `[ปีงบ]_[หน่วยงาน]_[ชื่อโครงการ]`

---

## Quick Commands (Claude)

| คำสั่ง | ผลลัพธ์ |
|--------|---------|
| "สร้างโครงการรัฐ X" | สร้างไฟล์ใน `03-government\proposals\` |
| "เขียน backtest กลยุทธ์ Y" | สร้างใน `02-trading\strategies\` + `backtests\` |
| "ทำ n8n workflow Z" | export JSON → `01-ai-systems\workflows\` |
| "ใช้ template อันเดิม" | อ่านจาก `99-shared\templates\` |

---

_Updated: 2026-05-14_
