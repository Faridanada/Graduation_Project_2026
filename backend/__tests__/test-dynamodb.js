require('dotenv').config();
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

console.log("Region:", process.env.AWS_REGION);

const client = new DynamoDBClient({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
});

const ddbDocClient = DynamoDBDocumentClient.from(client);

async function testConnection() {
  try {
    const data = await ddbDocClient.send(new ScanCommand({ TableName: 'Users' }));
    console.log("Successfully connected to DynamoDB!");
    console.log("Users table item count:", data.Items ? data.Items.length : 0);
  } catch (err) {
    console.error("Error connecting to DynamoDB:", err.message);
  }
}

testConnection();
