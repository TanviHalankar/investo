from flask import Flask, request, jsonify
from flask_cors import CORS  # <-- Add this
import joblib
import numpy as np

# Load artifacts
model = joblib.load("best_mistake_model.pkl")
scaler = joblib.load("scaler.pkl")
encoder = joblib.load("label_encoder.pkl")

app = Flask(__name__)
CORS(app)  # <-- Allow requests from Flutter frontend

# Mapping for detailed descriptions
descriptions = {
    "Good Trade": "Your trade decision was sound, and you made a reasonable profit.",
    "Over-trading": "You are buying and selling too frequently, leading to small profits or losses. Try to hold longer before exiting.",
    "Bad Trade": "Your trade resulted in a significant loss. Review your strategy and risk management.",
    "Minor Loss": "This trade resulted in a small loss. Review your entry and exit strategy to reduce such mistakes in the future."
}

@app.route("/predict", methods=["POST"])
def predict():
    try:
        # Get features from request
        data = request.get_json()
        features = np.array(data["features"]).reshape(1, -1)

        # Scale features
        features_scaled = scaler.transform(features)

        # Predict and decode
        prediction = model.predict(features_scaled)
        decoded = encoder.inverse_transform(prediction)[0]

        # Attach description
        result = {
            "prediction": decoded,
            "description": descriptions.get(decoded, "No description available.")
        }

        return jsonify(result)

    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
