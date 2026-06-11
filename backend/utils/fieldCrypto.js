const crypto = require('crypto');

// Load encryption key at startup
const keyB64 = process.env.FIELD_ENCRYPTION_KEY;
if (!keyB64) {
  throw new Error("Missing required environment variable: FIELD_ENCRYPTION_KEY. Must be a 32-byte base64 string.");
}

const key = Buffer.from(keyB64, 'base64');
if (key.length !== 32) {
  throw new Error(`Invalid FIELD_ENCRYPTION_KEY length. Expected 32 bytes, got ${key.length} bytes.`);
}

/**
 * Encrypts a string or object.
 * Objects are JSON.stringified before encryption.
 * Null/undefined are returned as null.
 *
 * @param {string|object|null|undefined} plaintext
 * @returns {string|null} The encrypted string in format `v1:<iv_b64>:<ciphertext_b64>:<authTag_b64>`
 */
function encryptField(plaintext) {
  if (plaintext === null || plaintext === undefined) {
    return null;
  }

  const stringToEncrypt = typeof plaintext === 'object' ? JSON.stringify(plaintext) : String(plaintext);

  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);

  let ciphertext = cipher.update(stringToEncrypt, 'utf8', 'base64');
  ciphertext += cipher.final('base64');
  const authTag = cipher.getAuthTag().toString('base64');

  return `v1:${iv.toString('base64')}:${ciphertext}:${authTag}`;
}

/**
 * Decrypts a string.
 * If the value does not start with `v1:`, it is assumed to be legacy plaintext and returned as-is.
 * Objects/arrays are JSON.parsed automatically if possible.
 * Null/undefined are returned as null.
 *
 * @param {string|null|undefined} value
 * @returns {string|object|null}
 */
function decryptField(value) {
  if (value === null || value === undefined) {
    return null;
  }

  if (typeof value !== 'string' || !value.startsWith('v1:')) {
    // Return legacy plaintext as-is (could be an object already or unencrypted string)
    return value;
  }

  const parts = value.split(':');
  if (parts.length !== 4) {
    throw new Error('Invalid encrypted field format');
  }

  const [version, ivB64, ciphertextB64, authTagB64] = parts;
  const iv = Buffer.from(ivB64, 'base64');
  const authTag = Buffer.from(authTagB64, 'base64');

  const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
  decipher.setAuthTag(authTag);

  let decrypted;
  try {
    decrypted = decipher.update(ciphertextB64, 'base64', 'utf8');
    decrypted += decipher.final('utf8');
  } catch (error) {
    throw new Error('Decryption or authentication failed. The key or data may be invalid/tampered.');
  }

  // Attempt to parse JSON (for object fields)
  try {
    // A simplistic heuristic: if it looks like JSON, try to parse it
    if ((decrypted.startsWith('{') && decrypted.endsWith('}')) || (decrypted.startsWith('[') && decrypted.endsWith(']'))) {
      return JSON.parse(decrypted);
    }
  } catch (e) {
    // Fallback to string if parsing fails
  }

  return decrypted;
}

/**
 * Returns a SHA-256 hex digest of a token.
 *
 * @param {string} token
 * @returns {string}
 */
function hashResetToken(token) {
  if (!token) return token;
  return crypto.createHash('sha256').update(String(token)).digest('hex');
}

module.exports = {
  encryptField,
  decryptField,
  hashResetToken
};
