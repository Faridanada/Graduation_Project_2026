#!/bin/bash

# ========================================================
# RUN THIS SCRIPT ON YOUR WINDOWS LAPTOP (IN GIT BASH)
# ========================================================

# Replace this with the actual path to your .pem key
PEM_FILE="C:/path/to/your/key.pem"

# Your EC2 instance
EC2_HOST="ubuntu@flexio-rehab.duckdns.org"

# The local folder where the AI code is
LOCAL_AI_FOLDER="C:/Users/asus/Desktop/gradmodel"

# The remote folder where we will put it on EC2
REMOTE_TARGET="~/"

echo "🚀 Uploading AI Service to EC2..."
echo "This might take a minute..."

# SCP command to recursively copy the folder
scp -i "$PEM_FILE" -r "$LOCAL_AI_FOLDER" "$EC2_HOST:$REMOTE_TARGET"

if [ $? -eq 0 ]; then
    echo "✅ Upload Successful!"
    echo "Now SSH into your EC2 and run the setup script."
else
    echo "❌ Upload Failed. Did you set the correct PEM_FILE path?"
fi
