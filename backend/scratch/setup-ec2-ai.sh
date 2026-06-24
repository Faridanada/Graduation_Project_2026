#!/bin/bash

# ========================================================
# RUN THIS SCRIPT INSIDE YOUR EC2 INSTANCE (UBUNTU)
# ========================================================

echo "🚀 Setting up AI Service on EC2..."

# 1. Update system and install Python 3 & pip
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# 2. Go to the uploaded gradmodel folder
cd ~/gradmodel || { echo "❌ gradmodel folder not found!"; exit 1; }

# 3. Create a virtual environment and activate it
python3 -m venv venv
source venv/bin/activate

# 4. Install the AI requirements (FastAPI, Scikit-learn, etc)
echo "📦 Installing Python packages..."
pip install -r requirements.txt

# 5. Start the AI service using PM2 so it stays alive 24/7
# (Assuming PM2 is already installed for your Node backend)
echo "🔥 Starting AI Service with PM2..."
pm2 start "venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000" --name "ai-service"

pm2 save

echo "✅ AI Service is now running on port 8000!"
echo "Check logs with: pm2 logs ai-service"
echo "Don't forget to update your Node backend .env to AI_SERVICE_URL=http://localhost:8000"
