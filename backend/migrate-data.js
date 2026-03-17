require('dotenv').config();
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const usersData = require("./data/users");
const appointmentsData = require("./data/appointments");
const exercisesData = require("./data/exercises");
const { requestsList } = require("./data/requests");

const clientParams = { region: process.env.AWS_REGION || 'us-east-1' };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  clientParams.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}

const client = new DynamoDBClient(clientParams);
const ddbDocClient = DynamoDBDocumentClient.from(client);

async function migrateData() {
  console.log("Starting data migration to DynamoDB...");

  try {
    for (const user of usersData) {
      // Ensure 'id' is a string as defined in partition key
      const item = { ...user, id: user.id.toString() };
      await ddbDocClient.send(new PutCommand({ TableName: "Users", Item: item }));
    }
    console.log(`Migrated ${usersData.length} Users.`);

    console.log("Migration complete for Users table!");
  } catch (error) {
    console.error("Migration failed:", error);
  }
}

migrateData();
