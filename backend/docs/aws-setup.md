# AWS Setup for Smart Rehabilitation System

## 1. flexio-smart-waveforms S3 Bucket Setup

Do NOT create this bucket programmatically. Follow these steps in the AWS Console:

1. **Create Bucket**:
   - Bucket name: `flexio-smart-waveforms`
   - Region: `eu-north-1`
   - Object Ownership: ACLs disabled (recommended)
   - Block Public Access settings: **Block all public access** (must be checked)
   - Bucket Versioning: **Enable**
   - Default encryption: **Server-side encryption with Amazon S3 managed keys (SSE-S3)**
   - Bucket Key: **Enable**

## 2. IAM Policies

The application requires an IAM user (e.g. `rehabproj`) for local development and an EC2 IAM role (e.g. `flexio-smart-ec2-role`) for production. 

1. Go to IAM -> Users -> Select your user (or Role).
2. Add a new inline policy named `flexio-smart-waveforms-access`.
3. Use the following JSON policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::flexio-smart-waveforms",
                "arn:aws:s3:::flexio-smart-waveforms/*"
            ]
        }
    ]
}
```

This ensures the backend can flush CSV waveforms and generate signed URLs for reading without making the bucket public.
