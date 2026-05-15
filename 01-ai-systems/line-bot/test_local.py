#!/usr/bin/env python3
import requests
import json

print("Testing Line Bot -> Hermes connectivity...")
try:
    r = requests.get('http://hermes:11434/api/tags', timeout=5)
    print(f"✓ Hermes reachable. Status: {r.status_code}")
    print(f"Models available: {r.json()}")
except Exception as e:
    print(f"✗ Failed to reach Hermes: {e}")

print("\nTesting webhook POST (will fail without valid signature, but tests routing)...")
try:
    r = requests.post('http://localhost:5000/webhook', json={}, timeout=5)
    print(f"✓ Webhook endpoint responded. Status: {r.status_code}")
except Exception as e:
    print(f"✗ Webhook error: {e}")

print("\nDone.")
