const { getSignedReadUrl } = require('./s3Service');

/**
 * Attaches a signed URL for a user's profile image.
 * Maintains the original `profileImage` key, and adds `profileImageUrl`.
 * @param {Object} user 
 * @returns {Object} transformed user object
 */
async function attachImageUrls(user) {
  if (!user) return user;
  
  // Clone the object to avoid mutating the original DB reference
  const out = { ...user };
  
  if (user.profileImage) {
    out.profileImageUrl = await getSignedReadUrl(user.profileImage);
  }
  
  return out;
}

/**
 * Attaches signed URLs for a wound record's images.
 * @param {Object} wound 
 * @returns {Object} transformed wound object
 */
async function attachWoundImageUrls(wound) {
  if (!wound) return wound;
  
  const out = { ...wound };
  
  if (wound.imagePath) {
    out.imageUrl = await getSignedReadUrl(wound.imagePath);
  }
  
  return out;
}

module.exports = {
  attachImageUrls,
  attachWoundImageUrls,
};
