"""
s3_loader.py — Download session waveform CSVs from S3.
"""

import io
import json
import logging
import os
from typing import Optional

import boto3
import pandas as pd

logger = logging.getLogger(__name__)

BUCKET = os.getenv("AWS_S3_WAVEFORMS_BUCKET", "flexio-smart-waveforms")
REGION = os.getenv("AWS_REGION", "eu-north-1")


def _client():
    return boto3.client("s3", region_name=REGION)


def download_csv(key: str) -> Optional[pd.DataFrame]:
    """
    Download a CSV from S3 and return as a pandas DataFrame.
    Returns None if the object doesn't exist or is empty.
    """
    try:
        s3 = _client()
        obj = s3.get_object(Bucket=BUCKET, Key=key)
        body = obj["Body"].read()
        if not body:
            logger.warning(f"[s3] empty object: {key}")
            return None
        df = pd.read_csv(io.BytesIO(body))
        logger.info(f"[s3] loaded {key} ({len(df)} rows, {len(df.columns)} cols)")
        return df
    except s3.exceptions.NoSuchKey:
        logger.error(f"[s3] no such key: {key}")
        return None
    except Exception as e:
        logger.exception(f"[s3] failed to download {key}: {e}")
        return None


def download_session_csvs(s3_key_prefix: str):
    """
    Given a session prefix like 'sessions/<patientId>/<sessionId>/',
    download emg.csv and imu.csv and return as DataFrames.
    Returns (emg_df, imu_df, events_df) where any can be None.
    """
    prefix = s3_key_prefix.rstrip("/") + "/"
    emg_df = download_csv(prefix + "emg.csv")
    imu_df = download_csv(prefix + "imu.csv")

    # events.json is optional — try to fetch but don't fail
    events = None
    try:
        s3 = _client()
        obj = s3.get_object(Bucket=BUCKET, Key=prefix + "events.json")
        events = json.loads(obj["Body"].read())
    except Exception:
        events = []

    return emg_df, imu_df, events