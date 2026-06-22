const { S3Client } = require('@aws-sdk/client-s3');
const multer = require('multer');
const multerS3 = require('multer-s3');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const s3Params = { region: process.env.AWS_REGION || 'eu-north-1' };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  s3Params.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}
const s3 = new S3Client(s3Params);

/**
 * Factory function to create a multer-s3 uploader
 * @param {string} folder - The folder in S3 (e.g., 'profile-images', 'wound-images')
 * @param {function} getOwnerId - Function to extract owner ID from request
 * @param {number} maxSizeMB - Maximum file size in MB
 */
const createUploader = (folder, getOwnerId, maxSizeMB = 10) => {
  return multer({
    limits: {
      fileSize: maxSizeMB * 1024 * 1024,
    },
    fileFilter: (req, file, cb) => {
      const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp', 'application/octet-stream'];
      if (!allowedMimeTypes.includes(file.mimetype)) {
        return cb(new Error(`Invalid file type: ${file.mimetype}. Only JPEG, PNG, and WEBP are allowed.`));
      }
      cb(null, true);
    },
    storage: multerS3({
      s3: s3,
      bucket: process.env.AWS_S3_BUCKET,
      contentType: multerS3.AUTO_CONTENT_TYPE,
      metadata: function (req, file, cb) {
        cb(null, { fieldName: file.fieldname });
      },
      key: function (req, file, cb) {
        const ownerId = getOwnerId(req) || 'anonymous';
        const ext = path.extname(file.originalname).toLowerCase();
        const uuid = uuidv4();
        cb(null, `${folder}/${ownerId}/${uuid}${ext}`);
      }
    })
  });
};

module.exports = {
  profileImageUpload: createUploader('profile-images', (req) => {
    return req.user?.id || req.body.userId || req.body.email || 'anonymous';
  }, 10),
  
  woundImageUpload: createUploader('wound-images', (req) => {
    return req.body.patientId || req.user?.id || 'anonymous';
  }, 20),
};
