require('dotenv').config();
const { DynamoDBClient, DeleteTableCommand, CreateTableCommand, waitUntilTableNotExists, waitUntilTableExists } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'eu-north-1' });

async function run() {
  try {
    console.log("Deleting Users table...");
    await client.send(new DeleteTableCommand({ TableName: 'Users' }));
    console.log("Waiting for Users table deletion...");
    await waitUntilTableNotExists({ client, maxWaitTime: 60 }, { TableName: 'Users' });
  } catch (err) {
    if (err.name !== 'ResourceNotFoundException') {
      console.error("Error deleting table:", err);
      return;
    }
  }

  try {
    console.log("Creating Users table with id as Partition Key...");
    const params = {
      TableName: 'Users',
      AttributeDefinitions: [{ AttributeName: "id", AttributeType: "S" }],
      KeySchema: [{ AttributeName: "id", KeyType: "HASH" }],
      BillingMode: "PAY_PER_REQUEST",
    };
    await client.send(new CreateTableCommand(params));
    console.log("Waiting for Users table creation...");
    await waitUntilTableExists({ client, maxWaitTime: 60 }, { TableName: 'Users' });
    console.log("Recreated Users table successfully!");
  } catch (err) {
    console.error("Error creating table:", err);
  }
}
run();
