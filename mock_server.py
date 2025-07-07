#!/usr/bin/env python3
"""
Simple mock server for testing the Health Predictor Flutter app.
This server simulates health prediction responses based on the input data.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import random

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web testing

@app.route('/predict', methods=['POST'])
def predict_health():
    try:
        # Get the health data from the request
        health_data = request.get_json()
        
        if not health_data:
            return jsonify({'error': 'No health data provided'}), 400
        
        print(f"Received health data: {health_data}")
        
        # Extract health metrics
        steps = health_data.get('step_count', 0)
        heart_rate = health_data.get('heart_rate_bpm', 0)
        sleep_minutes = health_data.get('total_sleep_minutes', 0)
        calories = health_data.get('calories', 0)
        
        # Simple mock prediction logic
        predictions = {}
        
        # Diabetes prediction (based on activity and weight indicators)
        diabetes_risk = False
        if steps < 5000 or calories > 2500:
            diabetes_risk = random.choice([True, False])  # Add some randomness
        predictions['Diabetes'] = diabetes_risk
        
        # Heart Disease prediction (based on heart rate and activity)
        heart_disease_risk = False
        if heart_rate > 100 or heart_rate < 50 or steps < 3000:
            heart_disease_risk = random.choice([True, False])
        predictions['Heart Disease'] = heart_disease_risk
        
        # Sleep Disorder prediction (based on sleep duration)
        sleep_disorder_risk = False
        sleep_hours = sleep_minutes / 60
        if sleep_hours < 6 or sleep_hours > 10:
            sleep_disorder_risk = random.choice([True, False])
        predictions['Sleep Disorder'] = sleep_disorder_risk
        
        # Hypertension prediction (based on multiple factors)
        hypertension_risk = False
        if heart_rate > 90 or steps < 4000 or calories > 2300:
            hypertension_risk = random.choice([True, False])
        predictions['Hypertension'] = hypertension_risk
        
        print(f"Generated predictions: {predictions}")
        
        return jsonify(predictions)
        
    except Exception as e:
        print(f"Error processing request: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'Mock health prediction server is running'})

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'message': 'Health Predictor Mock Server',
        'endpoints': {
            '/predict': 'POST - Submit health data for prediction',
            '/health': 'GET - Health check'
        }
    })

if __name__ == '__main__':
    print("🏥 Starting Health Predictor Mock Server...")
    print("📡 Server will be available at:")
    print("   - Desktop: http://127.0.0.1:5000")
    print("   - Android Emulator: http://10.0.2.2:5000")
    print("🔄 Use Ctrl+C to stop the server")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
