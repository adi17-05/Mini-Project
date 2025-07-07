#!/usr/bin/env python3
"""
Test script for the Advanced ML Health Prediction Server
Tests the server with the exact data format expected from the Flutter app
"""

import requests
import json

def test_health_prediction():
    # Test data matching the user's requirements
    test_data = {
        "step_count": 1000,
        "calories": 800,
        "total_sleep_minutes": 120,
        "bmi": 34.5,
        "heart_rate_bpm": 95,
        "spo2": 88,
        "stress_level": 5
    }
    
    print("🧪 Testing Advanced ML Health Prediction Server")
    print("=" * 50)
    print(f"📊 Input Data: {json.dumps(test_data, indent=2)}")
    print("=" * 50)
    
    try:
        # Test health check endpoint
        print("🔍 Testing health check endpoint...")
        health_response = requests.get('http://localhost:5001/health')
        if health_response.status_code == 200:
            print("✅ Health check passed")
            print(f"   Response: {health_response.json()}")
        else:
            print("❌ Health check failed")
            return
        
        print("\n🔍 Testing prediction endpoint...")
        
        # Test prediction endpoint
        response = requests.post(
            'http://localhost:5001/predict',
            headers={'Content-Type': 'application/json'},
            json=test_data
        )
        
        if response.status_code == 200:
            prediction = response.json()
            print("✅ Prediction successful!")
            print("\n📋 PREDICTION RESULTS:")
            print("=" * 50)
            
            # Display health score
            if 'health_score' in prediction:
                print(f"🏥 Overall Health Score: {prediction['health_score']}/100")
            
            # Display risk level
            if 'risk_level' in prediction:
                print(f"⚠️  Overall Risk Level: {prediction['risk_level']}")
            
            # Display detailed risks
            if 'detailed_risks' in prediction:
                print("\n🔍 Detailed Risk Analysis:")
                for risk_type, risk_data in prediction['detailed_risks'].items():
                    percentage = risk_data.get('risk_percentage', 0)
                    level = risk_data.get('level', 'Unknown')
                    print(f"   • {risk_type.replace('_', ' ').title()}: {percentage}% ({level} Risk)")
            
            # Display recommendations
            if 'recommendations' in prediction:
                print("\n💡 Personalized Recommendations:")
                for i, rec in enumerate(prediction['recommendations'], 1):
                    print(f"   {i}. {rec}")
            
            print("\n" + "=" * 50)
            print("🎉 Test completed successfully!")
            
        else:
            print(f"❌ Prediction failed with status code: {response.status_code}")
            print(f"   Error: {response.text}")
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection failed - make sure the server is running on localhost:5001")
    except Exception as e:
        print(f"❌ Test failed with error: {e}")

if __name__ == '__main__':
    test_health_prediction()
