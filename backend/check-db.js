const dbService = require('./services/dbService');
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: 'us-east-1' });
const ddbDocClient = DynamoDBDocumentClient.from(client);

async function checkUsers() {
  try {
    const data = await ddbDocClient.send(new ScanCommand({
      TableName: "Users",
    }));
    console.log("Users in DB:");
    data.Items.forEach(user => {
      console.log(`- ${user.email} (${user.role})`);
      console.log(`  profileData: ${JSON.stringify(user.profileData)}`);
    });
  } catch (err) {
    console.error(err);
  }
}

checkUsers();
