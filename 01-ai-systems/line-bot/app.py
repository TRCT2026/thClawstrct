"""
Line OA Bot — Video Editing Command Handler
Receives commands from Line OA and sends to Hermes AI agent (Docker)
"""

from flask import Flask, request, jsonify
from linebot import LineBotApi, WebhookHandler
from linebot.exceptions import InvalidSignatureError
from linebot.models import MessageEvent, TextMessage, TextSendMessage
import os
import requests
import json
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Line OA Credentials
LINE_CHANNEL_ACCESS_TOKEN = os.getenv("LINE_CHANNEL_ACCESS_TOKEN")
LINE_CHANNEL_SECRET = os.getenv("LINE_CHANNEL_SECRET")

# Hermes AI Agent (Docker)
HERMES_API_URL = os.getenv("HERMES_API_URL", "http://localhost:11434")

line_bot_api = LineBotApi(LINE_CHANNEL_ACCESS_TOKEN)
handler = WebhookHandler(LINE_CHANNEL_SECRET)


@app.route("/webhook", methods=["POST"])
def webhook():
    """Receive webhook from Line OA"""
    signature = request.headers.get("X-Line-Signature")
    body = request.get_data(as_text=True)

    try:
        handler.handle(body, signature)
    except InvalidSignatureError:
        return "Invalid signature", 403

    return "OK", 200


@handler.add(MessageEvent, message=TextMessage)
def handle_message(event):
    """Handle text messages from Line OA"""
    user_id = event.source.user_id
    user_message = event.message.text

    # Send to Hermes AI agent
    try:
        response = send_to_hermes(user_message)
        reply_text = f"✅ Hermes processed:\n{response}"
    except Exception as e:
        reply_text = f"❌ Error: {str(e)}"

    line_bot_api.reply_message(event.reply_token, TextSendMessage(text=reply_text))


def send_to_hermes(command: str) -> str:
    """
    Send video editing command to Hermes AI agent
    
    Example commands:
    - "ตัดคลิป 0:30-1:45 จากไฟล์ video.mp4"
    - "รวมคลิป clip1.mp4 clip2.mp4"
    - "เพิ่ม subtitle ให้กับ output.mp4"
    """
    try:
        # Call Hermes API (via Ollama or local endpoint)
        payload = {
            "model": "hermes",
            "prompt": command,
            "stream": False
        }
        
        response = requests.post(
            f"{HERMES_API_URL}/api/generate",
            json=payload,
            timeout=60
        )
        response.raise_for_status()
        
        result = response.json()
        return result.get("response", "No response from Hermes")
    
    except requests.exceptions.ConnectionError:
        return "Cannot connect to Hermes API. Is Docker running?"
    except Exception as e:
        return f"Error communicating with Hermes: {str(e)}"


@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "OK"}), 200


if __name__ == "__main__":
    # Run on port 5000 (exposed via Docker)
    app.run(host="0.0.0.0", port=5000, debug=False)
