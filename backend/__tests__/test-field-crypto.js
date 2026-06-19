require('dotenv').config();

// We must set FIELD_ENCRYPTION_KEY before requiring fieldCrypto if it's not set
if (!process.env.FIELD_ENCRYPTION_KEY) {
  const crypto = require('crypto');
  process.env.FIELD_ENCRYPTION_KEY = crypto.randomBytes(32).toString('base64');
}

const assert = require('assert');
const { encryptField, decryptField, hashResetToken } = require('../utils/fieldCrypto');

function runTests() {
  console.log("Running fieldCrypto tests...");

  // 1. String encryption/decryption
  const sampleString = "Hello Secret World";
  const encryptedString = encryptField(sampleString);
  assert(encryptedString.startsWith('v1:'), "Should have v1: prefix");
  assert(encryptedString !== sampleString, "Should be encrypted");
  const decryptedString = decryptField(encryptedString);
  assert.strictEqual(decryptedString, sampleString, "String decryption failed");
  console.log("✅ String encryption/decryption passed");

  // 2. Object encryption/decryption
  const sampleObject = { foo: "bar", num: 42, nested: { baz: true } };
  const encryptedObject = encryptField(sampleObject);
  assert(encryptedObject.startsWith('v1:'), "Should have v1: prefix");
  const decryptedObject = decryptField(encryptedObject);
  assert.deepStrictEqual(decryptedObject, sampleObject, "Object decryption failed");
  console.log("✅ Object encryption/decryption passed");

  // 3. Array encryption/decryption
  const sampleArray = [{ event: "simulated", ts: 123 }, { event: "stop", ts: 456 }];
  const encryptedArray = encryptField(sampleArray);
  assert(encryptedArray.startsWith('v1:'), "Array should have v1: prefix");
  const decryptedArray = decryptField(encryptedArray);
  assert.deepStrictEqual(decryptedArray, sampleArray, "Array decryption failed");
  assert(Array.isArray(decryptedArray), "Decrypted array should be an array type");
  console.log("✅ Array encryption/decryption passed");

  // 3. Legacy plaintext fallback
  const legacyString = "just a normal string";
  const decryptedLegacy = decryptField(legacyString);
  assert.strictEqual(decryptedLegacy, legacyString, "Legacy string decryption failed");
  
  const legacyObject = { legacy: true };
  const decryptedLegacyObject = decryptField(legacyObject);
  assert.deepStrictEqual(decryptedLegacyObject, legacyObject, "Legacy object decryption failed");
  console.log("✅ Legacy plaintext fallback passed");

  // 4. Null/undefined handling
  assert.strictEqual(encryptField(null), null, "encryptField(null) should return null");
  assert.strictEqual(encryptField(undefined), null, "encryptField(undefined) should return null");
  assert.strictEqual(decryptField(null), null, "decryptField(null) should return null");
  assert.strictEqual(decryptField(undefined), null, "decryptField(undefined) should return null");
  console.log("✅ Null/undefined handling passed");

  // 5. Hash reset token
  const token = "my-secret-token";
  const hash1 = hashResetToken(token);
  const hash2 = hashResetToken(token);
  assert.strictEqual(hash1, hash2, "Hashing should be deterministic");
  assert.strictEqual(hash1.length, 64, "SHA-256 hex digest should be 64 characters");
  assert(hash1 !== token, "Should be hashed");
  console.log("✅ Reset token hashing passed");

  console.log("🎉 All tests passed!");
}

runTests();
