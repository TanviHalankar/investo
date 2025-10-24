from flask import Flask, request, jsonify
from flask_cors import CORS
import random

app = Flask(__name__)
CORS(app)


@app.route('/')
def home():
    return "✅ StockWise AI Backend (Candlestick Reader Enhanced) is running!"


@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json(silent=True) or {}
    user_message = data.get("message", "").strip()

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    lower_msg = user_message.lower()
    reply = ""
    chart_data = None

    # --- Greetings ---
    if any(word in lower_msg for word in ["hi", "hello", "hey", "greetings"]):
        responses = [
            "Hey there! 👋 I'm **StockWise AI**, your investing guide. Want to learn how to read candlesticks or SIP charts?",
            "Hello! 📊 Curious about stock chart reading or price patterns? Let’s explore together!",
            "Hi! 😊 I can teach you how to understand candlestick charts, trends, and market signals."
        ]
        reply = random.choice(responses)

    # --- Candlestick Chart Explanation ---
    elif any(keyword in lower_msg for keyword in [
        "candlestick", "candle stick", "read candles", "how to read candles",
        "read candlestick", "understand candles", "interpret candles"
    ]):
        responses = [
            "🕯️ A **candlestick** shows how a stock’s price moved in a time period. Each candle has:\n"
            "• **Body** – the range between open & close prices.\n"
            "• **Wick/Shadow** – the highest and lowest prices.\n"
            "• **Color** – green (price went up) or red (price went down).",

            "📘 To **read candles**:\n"
            "1️⃣ A **green candle** = price closed higher than it opened.\n"
            "2️⃣ A **red candle** = price closed lower.\n"
            "3️⃣ Long wicks show volatility — buyers/sellers fought hard.\n"
            "4️⃣ Small bodies show indecision (called a *doji*).",

            "💡 Quick reading tips:\n"
            "- If the candle closes above open → buyers dominated (bullish).\n"
            "- If it closes below open → sellers dominated (bearish).\n"
            "- Watch for patterns like **Hammer, Doji, Engulfing** — they predict trend reversals.",

            "🟩 **Green candle** → market bullish (buyers strong).\n"
            "🟥 **Red candle** → market bearish (sellers strong).\n"
            "📊 Combine multiple candles to see trends — rising greens = uptrend, falling reds = downtrend."
        ]
        reply = random.choice(responses)

        chart_data = {
            "type": "candlestick",
            "title": "Example Candlestick Chart",
            "x": ["Mon", "Tue", "Wed", "Thu", "Fri"],
            "open": [120, 130, 125, 140, 138],
            "close": [130, 125, 140, 138, 145],
            "high": [132, 135, 142, 142, 147],
            "low": [118, 122, 123, 136, 137]
        }

    # --- Stock Basics ---
    elif "stock" in lower_msg or "share" in lower_msg:
        responses = [
            "📈 **Stocks** represent ownership in a company. Their prices rise and fall based on demand, performance, and market trends.",
            "💹 Buying a **stock** means owning a part of a company. Price changes reflect market confidence and growth potential.",
            "📊 Stocks can be visualized using candlestick or line charts to see price movements."
        ]
        reply = random.choice(responses)
        chart_data = {
            "type": "line",
            "title": "Stock Price Trend Example",
            "x": ["Mon", "Tue", "Wed", "Thu", "Fri"],
            "y": [130, 142, 137, 150, 160],
            "label": "Stock Price (₹)"
        }

    # --- Mutual Funds ---
    elif "mutual fund" in lower_msg or "mutualfund" in lower_msg:
        responses = [
            "💼 **Mutual funds** pool investors’ money and invest in diversified assets — stocks, bonds, or both.",
            "📘 A mutual fund’s performance is tracked by **NAV (Net Asset Value)** — the price per unit.",
            "🌱 Mutual funds are great for passive investors — diversification reduces risk."
        ]
        reply = random.choice(responses)
        chart_data = {
            "type": "line",
            "title": "Mutual Fund NAV Growth",
            "x": ["2020", "2021", "2022", "2023", "2024"],
            "y": [10, 12.5, 14.8, 17.6, 19.2],
            "label": "NAV (₹)"
        }

    # --- SIP ---
    elif "sip" in lower_msg:
        responses = [
            "📅 A **Systematic Investment Plan (SIP)** lets you invest a fixed amount monthly — great for consistency and compounding.",
            "💰 SIPs use *rupee cost averaging* — you buy more when prices drop and less when they rise.",
            "🌟 SIPs are perfect for long-term investors — time and consistency beat timing the market."
        ]
        reply = random.choice(responses)
        chart_data = {
            "type": "area",
            "title": "SIP Growth Over 10 Years",
            "x": list(range(1, 11)),
            "y": [12000, 25000, 39000, 55000, 73000, 94000, 118000, 145000, 175000, 210000],
            "label": "Total Value (₹)"
        }

    # --- Diversification / Risk ---
    elif any(word in lower_msg for word in ["risk", "diversify", "portfolio"]):
        responses = [
            "⚖️ Diversification spreads your risk across various assets like stocks, bonds, and gold.",
            "📊 A diversified portfolio protects you from market swings — if one asset drops, another may rise.",
            "💡 Don’t put all your eggs in one basket — that’s the key to smart investing."
        ]
        reply = random.choice(responses)
        chart_data = {
            "type": "pie",
            "title": "Sample Diversified Portfolio",
            "labels": ["Equity", "Debt", "Gold", "Cash"],
            "values": [50, 30, 15, 5]
        }

    # --- Fallback ---
    else:
        responses = [
            f"🤔 I’m not connected to a live AI model yet, but I received: “{user_message}”. Try asking about *how to read candles*, *mutual funds*, or *SIP charts*.",
            f"📩 You said: “{user_message}”. I can explain *candlestick reading*, *stock charts*, or *portfolio diversification*."
        ]
        reply = random.choice(responses)

    return jsonify({
        "reply": reply,
        "chart": chart_data
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
