require('dotenv').config();
const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'eu-north-1' });

async function run() {
  try {
    const data = await client.send(new ScanCommand({ TableName: 'Users' }));
    console.log(`Count: ${data.Count}`);
    if (data.Count > 0) {
      console.log(JSON.stringify(data.Items.slice(0, 2), null, 2));
    }
  } catch (err) {
    console.error(err);
  }
}
run();
