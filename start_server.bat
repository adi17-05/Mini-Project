@echo off
echo Installing Python dependencies...
pip install -r requirements.txt

echo.
echo Starting Health Predictor Mock Server...
python mock_server.py

pause
