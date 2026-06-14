require('dotenv').config();
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const dbService = require('../services/dbService');

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'eu-north-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  }
});

const getBucket = () => process.env.AWS_S3_BUCKET;

const getContentType = (filePath) => {
  const ext = path.extname(filePath).toLowerCase();
  if (ext === '.jpg' || ext === '.jpeg') return 'image/jpeg';
  if (ext === '.png') return 'image/png';
  if (ext === '.webp') return 'image/webp';
  return 'application/octet-stream';
};

const uploadFileToS3 = async (localFilePath, s3Key) => {
  const fileStream = fs.createReadStream(localFilePath);
  const contentType = getContentType(localFilePath);

  const command = new PutObjectCommand({
    Bucket: getBucket(),
    Key: s3Key,
    Body: fileStream,
    ContentType: contentType,
  });

  await s3Client.send(command);
  return s3Key;
};

const isLegacyPath = (imagePath) => {
  if (!imagePath) return false;
  // If it's already an http URL, it's either external or an old absolute URL.
  // Wait, if it's an old absolute URL we might need to migrate it.
  // But the prompt says "doesn't start with profile-images/, wound-images/, or any other S3 prefix (i.e. legacy local paths)"
  // Usually legacy paths in DB were stored as "uploads\\..." or "uploads/...".
  // If it starts with http, we can skip it, because it might be a Google/Facebook placeholder, 
  // or if they had absolute URLs we might not have the local file.
  if (imagePath.startsWith('http')) return false;
  
  if (imagePath.startsWith('profile-images/')) return false;
  if (imagePath.startsWith('wound-images/')) return false;
  
  return true;
};

const resolveLocalPath = (dbPath) => {
  // If dbPath is like "uploads/xyz.jpg", we resolve it relative to backend root
  // backend root is one level up from scripts
  const backendRoot = path.join(__dirname, '..');
  return path.resolve(backendRoot, dbPath);
};

const migrateUsers = async () => {
  console.log('--- Starting Users Migration ---');
  // Hack to scan users: dbService.getAllPatients or similar doesn't get doctors.
  // We'll use a raw scan if dbService exposes DynamoDB, or we can use dbService methods.
  // Actually, we can fetch all patients and doctors.
  const patients = await dbService.getAllPatients({});
  const doctors = await dbService.getAllDoctors({});
  const allUsers = [...patients, ...doctors];

  for (const user of allUsers) {
    if (isLegacyPath(user.profileImage)) {
      const localFilePath = resolveLocalPath(user.profileImage);
      if (fs.existsSync(localFilePath)) {
        const ext = path.extname(localFilePath);
        const newKey = `profile-images/${user.id}/${uuidv4()}${ext}`;
        
        try {
          await uploadFileToS3(localFilePath, newKey);
          await dbService.updateUserProfile(user.id, { profileImage: newKey });
          console.log(`[migrate] user=${user.id} local=${user.profileImage} -> s3=${newKey}`);
        } catch (err) {
          console.error(`[error] Failed to migrate user=${user.id} local=${user.profileImage}: ${err.message}`);
        }
      } else {
        console.log(`[skip] user=${user.id} local file not found: ${localFilePath}`);
      }
    }
  }
};

const migrateWounds = async () => {
  console.log('--- Starting Wounds Migration ---');
  // Need to get all wounds. There's no getAllWounds in dbService easily exposed without patientId,
  // but we can iterate over all patients and call getPatientWounds.
  const patients = await dbService.getAllPatients({});
  
  for (const patient of patients) {
    const wounds = await dbService.getPatientWounds(patient.id);
    for (const wound of wounds) {
      if (isLegacyPath(wound.imagePath)) {
        const localFilePath = resolveLocalPath(wound.imagePath);
        if (fs.existsSync(localFilePath)) {
          const ext = path.extname(localFilePath);
          const newKey = `wound-images/${wound.patientId}/${uuidv4()}${ext}`;
          
          try {
            await uploadFileToS3(localFilePath, newKey);
            // dbService doesn't have an updateWoundImagePath method.
            // Let's use the underlying dynamoDB update.
            const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
            const { DynamoDBDocumentClient, UpdateCommand } = require("@aws-sdk/lib-dynamodb");
            const client = new DynamoDBClient({ region: process.env.AWS_REGION || "eu-north-1" });
            const docClient = DynamoDBDocumentClient.from(client);
            
            await docClient.send(new UpdateCommand({
              TableName: "Wounds",
              Key: { id: wound.id },
              UpdateExpression: "set imagePath = :ip",
              ExpressionAttributeValues: { ":ip": newKey }
            }));
            
            console.log(`[migrate] wound=${wound.id} patient=${wound.patientId} local=${wound.imagePath} -> s3=${newKey}`);
          } catch (err) {
            console.error(`[error] Failed to migrate wound=${wound.id} local=${wound.imagePath}: ${err.message}`);
          }
        } else {
          console.log(`[skip] wound=${wound.id} local file not found: ${localFilePath}`);
        }
      }
    }
  }
};

const run = async () => {
  try {
    await migrateUsers();
    await migrateWounds();
    console.log('--- Migration Complete ---');
  } catch (err) {
    console.error('Migration failed:', err);
  }
};

run();
