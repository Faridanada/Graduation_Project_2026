require('dotenv').config();
const dbService = require('../services/dbService');

async function registerTestDevice() {
  // Hardcoded patientId that you used for your mock tests
  const patientId = "1773960006547";
  
  // The ID you want to give your ESP32
  const deviceId = "dev_test_001";
  const mqttUsername = "esp32_user";

  try {
    console.log(`Registering device '${deviceId}' for patient '${patientId}'...`);
    const device = await dbService.registerDevice(patientId, deviceId, mqttUsername);
    console.log("Success! Device registered:", device);
    console.log("\nNow you can configure your ESP32 to send to:");
    console.log(`Topic: flexio/${deviceId}/bundle`);
    console.log(`And make sure the JSON payload has "deviceId": "${deviceId}"`);
  } catch (err) {
    console.error("Failed to register device:", err.message);
  }
}

registerTestDevice();
