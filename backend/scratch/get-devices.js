require('dotenv').config();
const dbService = require('./services/dbService');
const { ScanCommand } = require("@aws-sdk/lib-dynamodb");

async function scanDevices() {
  try {
    const response = await dbService.ddbDocClient.send(new ScanCommand({
      TableName: "Devices"
    }));
    
    console.log("Registered Devices in Database:");
    console.log(JSON.stringify(response.Items, null, 2));
  } catch (error) {
    console.error("Error scanning devices:", error);
  }
}

scanDevices();
