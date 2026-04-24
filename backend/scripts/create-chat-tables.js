require('dotenv').config();
const { DynamoDBClient, CreateTableCommand } = require("@aws-sdk/client-dynamodb");

const clientParams = { region: process.env.AWS_REGION || 'us-east-1' };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  clientParams.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}

const client = new DynamoDBClient(clientParams);

const tablesToCreate = [
  "Messages",
  "Notifications"
];

async function createTables() {
  console.log("Starting chat/notification table creation in DynamoDB...");

  for (const tableName of tablesToCreate) {
    const params = {
      TableName: tableName,
      AttributeDefinitions: [
        { AttributeName: "id", AttributeType: "S" }
      ],
      KeySchema: [
        { AttributeName: "id", KeyType: "HASH" } // Partition key
      ],
      BillingMode: "PAY_PER_REQUEST", // Serverless pricing
    };

    try {
      console.log(`Creating table: ${tableName}...`);
      const command = new CreateTableCommand(params);
      await client.send(command);
      console.log(`✅ Successfully initiated creation of table: ${tableName}`);
    } catch (error) {
      if (error.name === "ResourceInUseException") {
        console.log(`⚠️ Table ${tableName} already exists. Skipping.`);
      } else {
        console.error(`❌ Failed to create table ${tableName}:`, error.message);
      }
    }
  }
}

createTables();
