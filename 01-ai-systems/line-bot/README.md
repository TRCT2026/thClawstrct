# Line OA Bot Integration with Hermes AI

## Setup

### 1. Get Line OA Credentials
1. Go to [Line Developer Console](https://developers.line.biz/console/)
2. Create Channel → Messaging API
3. Copy:
   - **Channel Access Token** → `.env` `LINE_CHANNEL_ACCESS_TOKEN`
   - **Channel Secret** → `.env` `LINE_CHANNEL_SECRET`

### 2. Setup Environment
```bash
cd ~/thClaws/01-ai-systems/line-bot
cp .env.example .env
# Edit .env with your Line credentials
```

### 3. Configure Line OA Webhook URL
1. In Line Developer Console → Messaging API settings
2. Set **Webhook URL** to:
   ```
   https://your-domain.com/webhook
   ```
   (or use ngrok for local testing)

### 4. Run with Docker
```bash
cd ~/thClaws/01-ai-systems
docker-compose up -d
```

### 5. Test
```bash
curl -X GET http://localhost:5000/health
```

## Architecture

```
Line OA (User sends command)
    ↓
Line Webhook → line-bot (Flask, :5000)
    ↓
Hermes AI Agent (Ollama, :11434)
    ↓
Response → Line OA (Send back result)
```

## Example Commands to Line OA Bot

- "ตัดคลิป 0:30-1:45 จากไฟล์ video.mp4"
- "รวมคลิป clip1.mp4 clip2.mp4"
- "เพิ่ม subtitle ให้กับ output.mp4"

## Logs
```bash
docker-compose logs -f line-bot
docker-compose logs -f hermes
```

## Stop
```bash
docker-compose down
```
