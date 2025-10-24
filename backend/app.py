from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os
import requests
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app, resources={r"/chat": {"origins": "*"}})

# Allow overriding via environment variable
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434/api/generate")
MODEL_NAME = os.getenv("OLLAMA_MODEL", "llama3")
DEFAULT_NUM_PREDICT = int(os.getenv("OLLAMA_NUM_PREDICT", 256))
DEFAULT_TEMPERATURE = float(os.getenv("OLLAMA_TEMPERATURE", 0.7))

@app.route('/')
def home():
    return "StockWise AI Chatbot Backend (Ollama Version) is running!"

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json(silent=True) or {}
    user_message = data.get("message", "").strip()

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    payload = {
        "model": MODEL_NAME,
        "prompt": (
            "You are a friendly stock market tutor. Answer concisely (<=120 words).\n"
            f"User: {user_message}\n"
            "Assistant:"
        ),
        "stream": True,
        "options": {
            "num_predict": DEFAULT_NUM_PREDICT,
            "temperature": DEFAULT_TEMPERATURE,
            "stop": ["\nUser:", "\nuser:"]
        },
    }

    try:
        resp = requests.post(OLLAMA_URL, json=payload, stream=True, timeout=(10, 300))
        if resp.status_code != 200:
            return jsonify({
                "error": "Ollama returned non-200",
                "status": resp.status_code,
                "details": resp.text[:500]
            }), 502

        full = ""
        for line in resp.iter_lines(decode_unicode=True):
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            if "response" in obj:
                full += obj["response"]
            if obj.get("done"):
                break
        return jsonify({"reply": full.strip()})

    except requests.exceptions.RequestException as e:
        return jsonify({"error": "Ollama request failed", "details": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
