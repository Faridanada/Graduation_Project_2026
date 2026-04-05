require("dotenv").config();
const fs = require("fs");

async function debugRequests() {
  const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
  const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");
  const client = new DynamoDBClient({
    region: process.env.AWS_REGION || "us-east-1",
    credentials: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    },
  });
  const ddbDocClient = DynamoDBDocumentClient.from(client);

  const reqs = await ddbDocClient.send(new ScanCommand({ TableName: "Requests" }));
  const users = await ddbDocClient.send(new ScanCommand({ TableName: "Users" }));
  
  const pats = users.Items.filter(u => u.role === "patient");
  
  const result = {
    requests: reqs.Items,
    patients: pats.map(p => ({
      id: p.id,
      assignedDoctorId: p.assignedDoctorId,
      profileData: p.profileData
    }))
  };

  fs.writeFileSync("out2.json", JSON.stringify(result, null, 2), "utf-8");
  console.log("Done");
}

debugRequests();
