require('dotenv').config();
const { DynamoDBClient, CreateTableCommand, DescribeTableCommand } = require("@aws-sdk/client-dynamodb");

const clientParams = { region: process.env.AWS_REGION || 'us-east-1' };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  clientParams.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}

const client = new DynamoDBClient(clientParams);

async function checkAndCreateRequestsTable() {
  const tableName = "Requests";
  try {
    await client.send(new DescribeTableCommand({ TableName: tableName }));
    console.log(`Table '${tableName}' already exists.`);
  } catch (error) {
    if (error.name === 'ResourceNotFoundException') {
      console.log(`Table '${tableName}' not found. Creating...`);
      const command = new CreateTableCommand({
        TableName: tableName,
        AttributeDefinitions: [
          { AttributeName: "id", AttributeType: "S" }
        ],
        KeySchema: [
          { AttributeName: "id", KeyType: "HASH" } // Partition key
        ],
        ProvisionedThroughput: {
          ReadCapacityUnits: 5,
          WriteCapacityUnits: 5,
        },
      });
      await client.send(command);
      console.log(`Table '${tableName}' created successfully!`);
    } else {
      console.error("Error describing table:", error);
    }
  }
}

checkAndCreateRequestsTable();
