const { S3Client, DeleteObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const s3Params = { region: process.env.AWS_REGION || 'eu-north-1' };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  s3Params.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}
const s3Client = new S3Client(s3Params);

const getBucket = () => process.env.AWS_S3_BUCKET;

/**
 * Generates a pre-signed GET URL for an S3 object.
 * @param {string} key - The S3 object key
 * @param {number} expiresInSeconds - Time until the URL expires (default 3600s / 1h)
 * @returns {Promise<string|null>}
 */
async function getSignedReadUrl(key, expiresInSeconds = 3600, bucketName = null) {
  if (!key) return null;
  
  // If it's already a full URL (legacy fallback), return it as is or handle it
  if (key.startsWith('http')) return key;

  try {
    const command = new GetObjectCommand({
      Bucket: bucketName || getBucket(),
      Key: key,
    });
    const url = await getSignedUrl(s3Client, command, { expiresIn: expiresInSeconds });
    return url;
  } catch (error) {
    console.error(`Error generating signed URL for key ${key}:`, error);
    return null; // Return null on failure rather than crashing
  }
}

/**
 * Deletes an object from S3.
 * @param {string} key - The S3 object key to delete
 */
async function deleteObject(key) {
  if (!key) return;
  if (key.startsWith('http')) return; // Can't delete by full URL easily here, or might be external

  try {
    const command = new DeleteObjectCommand({
      Bucket: getBucket(),
      Key: key,
    });
    await s3Client.send(command);
  } catch (error) {
    console.error(`Failed to delete object from S3: ${key}`, error.message);
    // Do not throw; orphaned objects are recoverable and shouldn't break the main flow.
  }
}

module.exports = {
  getSignedReadUrl,
  deleteObject,
};
