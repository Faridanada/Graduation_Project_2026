const usersData = require("../data/users");

// ==========================================
// DB Simulation (Before DynamoDB Access)
// ==========================================
// This file acts as an abstraction layer for the database.
// When DynamoDB is ready:
// 1. Install AWS SDK (already in package.json)
// 2. Configure DynamoDB Client
// 3. Update the functions below to use `dynamodb.put()` and `dynamodb.scan()`.
// 
// No changes will be needed in the Controllers or Routes, 
// as long as these functions return the expected Promises.

const dbService = {
  
  /**
   * Find a user by their email
   * @param {string} email 
   * @returns {Promise<Object|null>} The user object if found, null otherwise
   */
  async getUserByEmail(email) {
    return new Promise((resolve) => {
      // Simulate network delay
      setTimeout(() => {
        const user = usersData.find(u => u.email === email);
        resolve(user || null);
      }, 100);
    });
  },

  /**
   * Find a user by their ID
   * @param {string} id 
   * @returns {Promise<Object|null>} The user object if found, null otherwise
   */
  async getUserById(id) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const user = usersData.find(u => u.id === id);
        resolve(user || null);
      }, 100);
    });
  },

  /**
   * Create a new user
   * @param {Object} userData 
   * @returns {Promise<Object>} The created user object
   */
  async createUser(userData) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const newUser = {
          id: Date.now().toString(),
          ...userData,
          createdAt: new Date().toISOString()
        };
        usersData.push(newUser);
        resolve(newUser);
      }, 150);
    });
  }
};

module.exports = dbService;
