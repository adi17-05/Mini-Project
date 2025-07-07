#!/usr/bin/env python3
"""
Advanced ML Health Prediction Server
Processes comprehensive health data and provides detailed risk analysis
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np

app = Flask(__name__)
CORS(app)

def calculate_health_risk(data):
    """Advanced health risk calculation based on multiple parameters"""
    step_count = data.get('step_count', 5000)
    calories = data.get('calories', 2000)
    sleep_minutes = data.get('total_sleep_minutes', 480)
    bmi = data.get('bmi', 25.0)
    heart_rate = data.get('heart_rate_bpm', 75)
    spo2 = data.get('spo2', 95)
    stress_level = data.get('stress_level', 3)
    
    # Convert sleep to hours
    sleep_hours = sleep_minutes / 60
    
    # Normalize values for scoring (0-1 scale)
    step_score = min(1.0, step_count / 10000)  # 10k steps = perfect
    sleep_score = 1.0 - abs(8 - sleep_hours) / 8  # 8 hours = perfect
    bmi_score = 1.0 - abs(22 - bmi) / 15  # BMI 22 = perfect
    hr_score = 1.0 - abs(70 - heart_rate) / 50  # 70 bpm = perfect
    spo2_score = min(1.0, spo2 / 98)  # 98% = perfect
    stress_score = 1.0 - (stress_level - 1) / 9  # Low stress = perfect
    
    # Ensure scores are between 0 and 1
    scores = [max(0, min(1, score)) for score in [step_score, sleep_score, bmi_score, hr_score, spo2_score, stress_score]]
    
    # Calculate overall health score
    overall_health = sum(scores) / len(scores) * 100
    
    # Calculate specific risk scores
    diabetes_risk = calculate_diabetes_risk(bmi, step_count, stress_level)
    cardiovascular_risk = calculate_cardiovascular_risk(heart_rate, bmi, stress_level, step_count)
    obesity_risk = calculate_obesity_risk(bmi, step_count, calories)
    sleep_disorder_risk = calculate_sleep_risk(sleep_hours, stress_level, heart_rate)
    
    return {
        "overall_health_score": round(overall_health, 1),
        "diabetes_risk": diabetes_risk,
        "cardiovascular_risk": cardiovascular_risk,
        "obesity_risk": obesity_risk,
        "sleep_disorder_risk": sleep_disorder_risk
    }

def calculate_diabetes_risk(bmi, steps, stress):
    """Calculate diabetes risk based on BMI, activity, and stress"""
    risk_score = 0
    if bmi > 30: risk_score += 40
    elif bmi > 25: risk_score += 20
    if steps < 5000: risk_score += 30
    elif steps < 8000: risk_score += 15
    if stress > 6: risk_score += 20
    elif stress > 4: risk_score += 10
    return min(100, risk_score)

def calculate_cardiovascular_risk(heart_rate, bmi, stress, steps):
    """Calculate cardiovascular risk"""
    risk_score = 0
    if heart_rate > 100: risk_score += 35
    elif heart_rate > 85: risk_score += 20
    if bmi > 30: risk_score += 25
    elif bmi > 25: risk_score += 15
    if stress > 6: risk_score += 25
    elif stress > 4: risk_score += 10
    if steps < 5000: risk_score += 15
    return min(100, risk_score)

def calculate_obesity_risk(bmi, steps, calories):
    """Calculate obesity risk"""
    risk_score = 0
    if bmi > 30: risk_score += 60
    elif bmi > 25: risk_score += 30
    if steps < 5000: risk_score += 25
    elif steps < 8000: risk_score += 10
    if calories > 3000: risk_score += 15
    return min(100, risk_score)

def calculate_sleep_risk(sleep_hours, stress, heart_rate):
    """Calculate sleep disorder risk"""
    risk_score = 0
    if sleep_hours < 6: risk_score += 40
    elif sleep_hours < 7: risk_score += 20
    elif sleep_hours > 9: risk_score += 15
    if stress > 6: risk_score += 30
    elif stress > 4: risk_score += 15
    if heart_rate > 85: risk_score += 15
    return min(100, risk_score)

def generate_recommendations(data, risks):
    """Generate personalized health recommendations"""
    recommendations = []
    
    step_count = data.get('step_count', 5000)
    sleep_minutes = data.get('total_sleep_minutes', 480)
    bmi = data.get('bmi', 25.0)
    heart_rate = data.get('heart_rate_bpm', 75)
    spo2 = data.get('spo2', 95)
    stress_level = data.get('stress_level', 3)
    
    # Activity recommendations
    if step_count < 5000:
        recommendations.append("🚶‍♂️ Increase daily activity - aim for 10,000 steps per day")
    elif step_count < 8000:
        recommendations.append("👍 Good activity level - try to reach 10,000 steps daily")
    
    # Sleep recommendations
    sleep_hours = sleep_minutes / 60
    if sleep_hours < 7:
        recommendations.append("😴 Prioritize sleep - aim for 7-9 hours nightly for optimal health")
    elif sleep_hours > 9:
        recommendations.append("⏰ Consider evaluating sleep quality - excessive sleep may indicate underlying issues")
    
    # BMI recommendations
    if bmi > 30:
        recommendations.append("⚖️ Consider weight management - consult healthcare provider for personalized plan")
    elif bmi > 25:
        recommendations.append("🥗 Maintain healthy weight through balanced diet and regular exercise")
    elif bmi < 18.5:
        recommendations.append("🍎 Consider healthy weight gain - consult nutritionist if needed")
    
    # Heart rate recommendations
    if heart_rate > 100:
        recommendations.append("❤️ Elevated heart rate detected - consider stress management and consult doctor")
    elif heart_rate > 85:
        recommendations.append("💓 Monitor heart rate - practice relaxation techniques")
    
    # SpO2 recommendations
    if spo2 < 95:
        recommendations.append("🫁 Low oxygen saturation - consult healthcare provider immediately")
    elif spo2 < 98:
        recommendations.append("🌬️ Consider breathing exercises and monitor oxygen levels")
    
    # Stress recommendations
    if stress_level > 6:
        recommendations.append("🧘‍♀️ High stress detected - try meditation, yoga, or stress management techniques")
    elif stress_level > 4:
        recommendations.append("😌 Practice stress reduction - regular exercise and relaxation help")
    
    # Risk-specific recommendations
    if risks['diabetes_risk'] > 50:
        recommendations.append("🩺 High diabetes risk - regular health checkups and blood sugar monitoring recommended")
    if risks['cardiovascular_risk'] > 50:
        recommendations.append("💗 Cardiovascular risk detected - heart-healthy diet and regular exercise important")
    if risks['obesity_risk'] > 50:
        recommendations.append("🏃‍♀️ Weight management crucial - combine cardio and strength training")
    if risks['sleep_disorder_risk'] > 50:
        recommendations.append("🛏️ Sleep issues detected - consider sleep hygiene improvements or sleep study")
    
    if not recommendations:
        recommendations.append("🌟 Excellent health metrics! Keep maintaining your healthy lifestyle")
    
    return recommendations

@app.route('/predict', methods=['POST'])
def predict_health():
    try:
        # Get health data from request
        health_data = request.json
        print(f"Received health data: {health_data}")
        
        # Validate required fields
        required_fields = ['step_count', 'calories', 'total_sleep_minutes', 'bmi', 'heart_rate_bpm', 'spo2', 'stress_level']
        for field in required_fields:
            if field not in health_data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
        
        # Calculate health risks
        risk_analysis = calculate_health_risk(health_data)
        
        # Generate recommendations
        recommendations = generate_recommendations(health_data, risk_analysis)
        
        # Determine overall risk level
        avg_risk = (risk_analysis['diabetes_risk'] + risk_analysis['cardiovascular_risk'] + 
                   risk_analysis['obesity_risk'] + risk_analysis['sleep_disorder_risk']) / 4
        
        if avg_risk < 30:
            risk_level = "Low"
            risk_color = "green"
        elif avg_risk < 60:
            risk_level = "Medium"
            risk_color = "orange"
        else:
            risk_level = "High"
            risk_color = "red"
        
        prediction = {
            "health_score": risk_analysis['overall_health_score'],
            "risk_level": risk_level,
            "risk_color": risk_color,
            "recommendations": recommendations,
            "detailed_risks": {
                "diabetes": {
                    "risk_percentage": risk_analysis['diabetes_risk'],
                    "level": "High" if risk_analysis['diabetes_risk'] > 60 else "Medium" if risk_analysis['diabetes_risk'] > 30 else "Low"
                },
                "cardiovascular": {
                    "risk_percentage": risk_analysis['cardiovascular_risk'],
                    "level": "High" if risk_analysis['cardiovascular_risk'] > 60 else "Medium" if risk_analysis['cardiovascular_risk'] > 30 else "Low"
                },
                "obesity": {
                    "risk_percentage": risk_analysis['obesity_risk'],
                    "level": "High" if risk_analysis['obesity_risk'] > 60 else "Medium" if risk_analysis['obesity_risk'] > 30 else "Low"
                },
                "sleep_disorders": {
                    "risk_percentage": risk_analysis['sleep_disorder_risk'],
                    "level": "High" if risk_analysis['sleep_disorder_risk'] > 60 else "Medium" if risk_analysis['sleep_disorder_risk'] > 30 else "Low"
                }
            },
            "input_data": health_data
        }
        
        return jsonify(prediction)
        
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "message": "Advanced Health Prediction API is running"})

if __name__ == '__main__':
    print("🏥 Advanced Health Prediction Server starting...")
    print("📡 Server will be available at: http://localhost:5001")
    print("🔗 Prediction endpoint: http://localhost:5001/predict")
    print("💚 Health check: http://localhost:5001/health")
    app.run(host='0.0.0.0', port=5001, debug=True)
