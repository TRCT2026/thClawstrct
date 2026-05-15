#!/usr/bin/env python3
import requests
import json

# Test 1: Check Ollama health
print("=== Test 1: Ollama Health ===")
try:
    r = requests.get('http://localhost:11434/api/tags', timeout=5)
    print(f"Status: {r.status_code}")
    data = r.json()
    print(f"Response: {json.dumps(data, indent=2)}")
except Exception as e:
    print(f"ERROR: {e}")

# Test 2: Check Line Bot health
print("\n=== Test 2: Line Bot Health ===")
try:
    r = requests.get('http://localhost:5000/health', timeout=5)
    print(f"Status: {r.status_code}")
    print(f"Response: {r.text}")
except Exception as e:
    print(f"ERROR: {e}")

# Test 3: Attempt Ollama generate (will fail if no model, but tests connectivity)
print("\n=== Test 3: Ollama Generate Endpoint ===")
try:
    payload = {"model": "test", "prompt": "hello", "stream": False}
    r = requests.post('http://localhost:11434/api/generate', json=payload, timeout=10)
    print(f"Status: {r.status_code}")
    print(f"Response preview: {r.text[:200]}")
except Exception as e:
    print(f"ERROR: {e}")

print("\nDone.")
