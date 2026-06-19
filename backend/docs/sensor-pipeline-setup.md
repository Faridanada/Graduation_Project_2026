# Sensor Telemetry Pipeline Setup

This guide explains how to set up the Mosquitto MQTT broker for the Smart Rehabilitation System telemetry pipeline.

## 1. Install Mosquitto

For Ubuntu/Debian:
```bash
sudo apt update
sudo apt install mosquitto mosquitto-clients
```

## 2. Configure Mosquitto (Local Dev)

We'll set up Mosquitto with password authentication. TLS is recommended for production but we use plain MQTT (port 1883) for local development.

Edit or create `/etc/mosquitto/conf.d/default.conf` or `/etc/mosquitto/mosquitto.conf`:

```
listener 1883 0.0.0.0
allow_anonymous false
password_file /etc/mosquitto/passwd
```

## 3. Create MQTT Users

Create a password file and add a backend server user (used by the Node.js subscriber):
```bash
sudo mosquitto_passwd -c /etc/mosquitto/passwd backend_server
# (Enter the password when prompted, and set it in your .env as MQTT_PASSWORD)
```

Add a device user (used by the ESP32):
```bash
sudo mosquitto_passwd /etc/mosquitto/passwd exo_device
```

Restart Mosquitto:
```bash
sudo systemctl restart mosquitto
```

## 4. Testing Locally

Open a terminal and subscribe using the backend credentials:
```bash
mosquitto_sub -h localhost -p 1883 -u backend_server -P "YOUR_BACKEND_PASSWORD" -t "flexio/+/emg"
```

In another terminal, publish a test message as a device:
```bash
mosquitto_pub -h localhost -p 1883 -u exo_device -P "YOUR_DEVICE_PASSWORD" -t "flexio/exo-001/emg" -m '{"ts": 1733000000000, "deviceId": "exo-001", "sensors": []}'
```
You should see the message arrive in the subscriber terminal.

## 5. Production (Future Work)
For production on EC2:
1. Ensure port 8883 is open in the AWS Security Group.
2. Obtain a Let's Encrypt SSL certificate.
3. Configure `listener 8883` in Mosquitto with `certfile` and `keyfile` pointing to the SSL certs.
4. Update the `.env` `MQTT_URL` to `mqtts://localhost:8883`.
