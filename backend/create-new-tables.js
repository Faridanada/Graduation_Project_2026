require("dotenv").config();
const { DynamoDBClient, CreateTableCommand } = require("@aws-sdk/client-dynamodb");

const clientParams = { region: process.env.AWS_REGION || "us-east-1" };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  clientParams.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}
const client = new DynamoDBClient(clientParams);

async function createTable(tableName) {
  try {
    await client.send(new CreateTableCommand({
      TableName: tableName,
      AttributeDefinitions: [{ AttributeName: "id", AttributeType: "S" }],
      KeySchema: [{ AttributeName: "id", KeyType: "HASH" }],
      BillingMode: "PAY_PER_REQUEST",
    }));
    console.log(`✅ ${tableName} table created successfully!`);
  } catch (err) {
    if (err.name === "ResourceInUseException") {
      console.log(`⚠️  ${tableName} table already exists.`);
    } else {
      console.error(`❌ Error creating ${tableName} table:`, err);
    }
  }
}

async function run() {
  await createTable("Sessions");
  await createTable("RecoveryPlans");
}

run();
