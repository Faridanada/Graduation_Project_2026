const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { 
  DynamoDBDocumentClient, 
  GetCommand, 
  PutCommand, 
  ScanCommand, 
  UpdateCommand,
  DeleteCommand
} = require("@aws-sdk/lib-dynamodb");

// Mock data imports commented out after DynamoDB migration
// const appointmentsData = require("../data/appointments");
// const exercisesData = require("../data/exercises");
// const { requestsList } = require("../data/requests");

// Initialize DynamoDB Client
// The SDK automatically falls back to EC2 IAM roles if access keys are missing from .env
const clientParams = { region: process.env.AWS_REGION || 'us-east-1' };
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
  clientParams.credentials = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  };
}

const client = new DynamoDBClient(clientParams);
const ddbDocClient = DynamoDBDocumentClient.from(client);

// ==========================================
// DB Simulation -> DYNAMODB IMPLEMENTATION
// ==========================================

const dbService = {

  async getUserByEmail(email) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Users",
        FilterExpression: "email = :email",
        ExpressionAttributeValues: { ":email": email }
      }));
      return data.Items && data.Items.length > 0 ? data.Items[0] : null;
    } catch (error) {
      console.error("DynamoDB error (getUserByEmail):", error);
      throw error;
    }
  },

  async getUserById(id) {
    try {
      const data = await ddbDocClient.send(new GetCommand({
        TableName: "Users",
        Key: { id }
      }));
      return data.Item || null;
    } catch (error) {
      console.error("DynamoDB error (getUserById):", error);
      throw error;
    }
  },

  async updateUserProfile(id, updates) {
    try {
      const user = await this.getUserById(id);
      if (!user) return null;

      if (updates.name) user.name = updates.name;
      if (updates.phoneNumber !== undefined) user.phoneNumber = updates.phoneNumber;
      
      if (updates.profileData) {
        user.profileData = { ...user.profileData, ...updates.profileData };
      }

      if (updates.twoFactorEnabled !== undefined) {
        user.twoFactorEnabled = updates.twoFactorEnabled;
      }
      
      if (updates.profileImage) {
        user.profileImage = updates.profileImage;
      }
      
      await ddbDocClient.send(new PutCommand({
        TableName: "Users",
        Item: user
      }));
      return user;
    } catch (error) {
      console.error("DynamoDB error (updateUserProfile):", error);
      throw error;
    }
  },

  async updateUserPassword(id, hashedPassword) {
    try {
      const user = await this.getUserById(id);
      if (!user) throw new Error("User not found");
      
      user.password = hashedPassword;

      await ddbDocClient.send(new PutCommand({
        TableName: "Users",
        Item: user
      }));
      return true;
    } catch (error) {
      console.error("DynamoDB error (updateUserPassword):", error);
      throw error;
    }
  },

  async saveResetToken(id, token, expiry) {
    try {
      const user = await this.getUserById(id);
      if (!user) return null;
      
      user.resetToken = token;
      user.resetTokenExpiry = expiry;
      
      await ddbDocClient.send(new PutCommand({
        TableName: "Users",
        Item: user
      }));
      return user;
    } catch (error) {
      console.error("DynamoDB error (saveResetToken):", error);
      throw error;
    }
  },

  async clearResetToken(id) {
    try {
      const user = await this.getUserById(id);
      if (!user) return null;
      
      delete user.resetToken;
      delete user.resetTokenExpiry;
      
      await ddbDocClient.send(new PutCommand({
        TableName: "Users",
        Item: user
      }));
      return user;
    } catch (error) {
      console.error("DynamoDB error (clearResetToken):", error);
      throw error;
    }
  },

  async createUser(userData) {
    try {
      const newUser = {
        id: Date.now().toString(),
        ...userData,
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Users",
        Item: newUser
      }));
      return newUser;
    } catch (error) {
      console.error("DynamoDB error (createUser):", error);
      throw error;
    }
  },

  async getPatientsForDoctor(doctorId) {
    try {
      // Scanning the Users table for patients assigned to THIS doctor
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Users",
        FilterExpression: "#userRole = :role AND assignedDoctorId = :doctorId",
        ExpressionAttributeNames: { "#userRole": "role" },
        ExpressionAttributeValues: { 
          ":role": "patient",
          ":doctorId": doctorId 
        }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getPatientsForDoctor):", error);
      throw error;
    }
  },

  async getAllPatients(filters = {}) {
    try {
      const { name } = filters;
      let filterExpression = "#roleAttr = :role";
      const expressionAttributeNames = {
        "#roleAttr": "role",
        "#nameAttr": "name"
      };
      const expressionAttributeValues = { ":role": "patient" };

      if (name) {
        filterExpression += " AND contains(#nameAttr, :name)";
        expressionAttributeValues[":name"] = name;
      }

      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Users",
        FilterExpression: filterExpression,
        ExpressionAttributeNames: expressionAttributeNames,
        ExpressionAttributeValues: expressionAttributeValues,
        ProjectionExpression: "id, #nameAttr, email, profileData, assignedDoctorId"
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getAllPatients):", error);
      throw error;
    }
  },

  async getPatientDetailsAndHistory(patientId) {
    try {
      // 1. Get the patient user profile
      const userResult = await ddbDocClient.send(new GetCommand({
        TableName: "Users",
        Key: { id: patientId }
      }));
      const user = userResult.Item;
      if (!user) return null;

      // 2. Get the patient's appointments
      const appointmentsData = await ddbDocClient.send(new ScanCommand({
        TableName: "Appointments",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));
      
      // 3. Get the patient's exercises
      const exercisesData = await ddbDocClient.send(new ScanCommand({
        TableName: "Exercises",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));
      
      // 4. Get the patient's reminders
      const remindersData = await ddbDocClient.send(new ScanCommand({
        TableName: "Reminders",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));

      return {
        profile: user,
        appointments: appointmentsData.Items || [],
        exercises: exercisesData.Items || [],
        reminders: remindersData.Items || []
      };
    } catch (error) {
      console.error("DynamoDB error (getPatientDetailsAndHistory):", error);
      throw error;
    }
  },

  async getDashboardStats(doctorId) {
    try {
      const patients = await this.getPatientsForDoctor(doctorId);
      
      const today = new Date().toISOString().split('T')[0];
      const appointmentsData = await ddbDocClient.send(new ScanCommand({
        TableName: "Appointments",
        FilterExpression: "doctorId = :doctorId AND #dateAttr = :today",
        ExpressionAttributeNames: { "#dateAttr": "date" },
        ExpressionAttributeValues: { ":doctorId": doctorId, ":today": today }
      }));
      const appointmentsToday = appointmentsData.Items || [];

      // Fetch real high-risk/unread alert count
      const notifications = await this.getNotificationsForUser(doctorId);
      // Exclude connection requests from the "Alerts" count as per user preference
      const alertsCount = notifications.filter(n => !n.isRead && n.title !== "New Connection Request").length;

      // Fetch pending reviews count from Wounds table
      const woundsData = await ddbDocClient.send(new ScanCommand({
        TableName: "Wounds",
        FilterExpression: "doctorId = :doctorId AND #statusAttr = :pendingStatus",
        ExpressionAttributeNames: { "#statusAttr": "status" },
        ExpressionAttributeValues: { 
          ":doctorId": doctorId, 
          ":pendingStatus": "pending review" 
        }
      }));
      const pendingReviewsCount = (woundsData.Items || []).length;

      return {
        activePatients: patients.length,
        todaySessions: appointmentsToday.length,
        alerts: alertsCount,
        pendingReviews: pendingReviewsCount,
      };
    } catch (error) {
      console.error("Error in getDashboardStats:", error);
      throw error;
    }
  },

  async getTodayAppointments(userId, role) {
    try {
      const today = new Date().toISOString().split('T')[0];
      const filterExpr = role === 'doctor' ? "doctorId = :userId" : "patientId = :userId";
      
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Appointments",
        FilterExpression: `${filterExpr} AND #dateAttr = :today`,
        ExpressionAttributeNames: { "#dateAttr": "date" },
        ExpressionAttributeValues: { ":userId": userId, ":today": today }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getTodayAppointments):", error);
      throw error;
    }
  },

  async getTodayExercises(patientId) {
    try {
      const today = new Date().toISOString().split('T')[0];
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Exercises",
        FilterExpression: "patientId = :patientId AND dateAssigned = :today",
        ExpressionAttributeValues: { ":patientId": patientId, ":today": today }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getTodayExercises):", error);
      throw error;
    }
  },

  // Get ALL exercises assigned to a patient (not just today)
  async getAllExercisesForPatient(patientId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Exercises",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getAllExercisesForPatient):", error);
      throw error;
    }
  },

  // Update repsCompleted and mark as done if all reps finished
  async updateExerciseProgress(exerciseId, patientId, repsCompleted) {
    try {
      const data = await ddbDocClient.send(new UpdateCommand({
        TableName: "Exercises",
        Key: { id: exerciseId },
        UpdateExpression: "SET repsCompleted = :reps, completedAt = :now",
        ExpressionAttributeValues: {
          ":reps": repsCompleted,
          ":now": new Date().toISOString()
        },
        ReturnValues: "ALL_NEW"
      }));
      return data.Attributes;
    } catch (error) {
      console.error("DynamoDB error (updateExerciseProgress):", error);
      throw error;
    }
  },


  async assignExercise(patientId, doctorId, exerciseData) {
    try {
      const newExercise = {
        id: `exercise_${Date.now()}`,
        patientId,
        doctorId,
        ...exerciseData,
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Exercises",
        Item: newExercise
      }));

      // Optionally notify the patient
      await this.createNotification(
        patientId,
        "New Exercise Assigned",
        "Your doctor has assigned a new exercise for you to complete."
      );

      return newExercise;
    } catch (error) {
      console.error("DynamoDB error (assignExercise):", error);
      throw error;
    }
  },

  async getReminders(patientId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Reminders",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getReminders):", error);
      throw error;
    }
  },

  async createReminder(patientId, text, type = 'general') {
    try {
      const newReminder = {
        id: `rem_${Date.now()}`,
        patientId,
        text,
        type,
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Reminders",
        Item: newReminder
      }));
      return newReminder;
    } catch (error) {
      console.error("DynamoDB error (createReminder):", error);
      throw error;
    }
  },

  async getRequests(doctorId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Requests",
        FilterExpression: "doctorId = :doctorId",
        ExpressionAttributeValues: { ":doctorId": doctorId }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getRequests):", error);
      throw error;
    }
  },

  async updateRequestStatus(requestId, status) {
    try {
      const data = await ddbDocClient.send(new UpdateCommand({
        TableName: "Requests",
        Key: { id: requestId },
        UpdateExpression: "set #statusAttr = :status",
        ExpressionAttributeNames: { "#statusAttr": "status" },
        ExpressionAttributeValues: { ":status": status },
        ReturnValues: "ALL_NEW"
      }));
      return data.Attributes;
    } catch (error) {
      console.error("DynamoDB error (updateRequestStatus):", error);
      throw error;
    }
  },

  async deleteRequest(requestId) {
    try {
      await ddbDocClient.send(new DeleteCommand({
        TableName: "Requests",
        Key: { id: requestId }
      }));
      return true;
    } catch (error) {
      console.error("DynamoDB error (deleteRequest):", error);
      throw error;
    }
  },

  async getAllDoctors(filters = {}) {
    try {
      const { name, specialty } = filters;
      let filterExpression = "#roleAttr = :role";
      const expressionAttributeNames = { 
        "#roleAttr": "role",
        "#nameAttr": "name"
      };
      const expressionAttributeValues = { ":role": "doctor" };

      if (name) {
        filterExpression += " AND contains(#nameAttr, :name)";
        expressionAttributeValues[":name"] = name;
      }
      if (specialty) {
        filterExpression += " AND contains(profileData.specialty, :specialty)";
        expressionAttributeValues[":specialty"] = specialty;
      }

      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Users",
        FilterExpression: filterExpression,
        ExpressionAttributeNames: expressionAttributeNames,
        ExpressionAttributeValues: expressionAttributeValues,
        ProjectionExpression: "id, #nameAttr, email, profileData"
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getAllDoctors):", error);
      throw error;
    }
  },

  async createRequest(patientId, doctorId, patientName, patientEmail) {
    try {
      const newRequest = {
        id: `req_${Date.now()}`,
        patientId,
        doctorId,
        patientName,
        patientEmail,
        status: 'pending',
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Requests",
        Item: newRequest
      }));

      // Notify the doctor about the new request
      await this.createNotification(
        doctorId,
        "New Connection Request",
        `Patient ${patientName} wants to connect with you.`
      );

      return newRequest;
    } catch (error) {
      console.error("DynamoDB error (createRequest):", error);
      throw error;
    }
  },

  async linkPatientToDoctor(patientId, doctorId) {
    try {
      // Updates the user table to set assignedDoctorId
      const data = await ddbDocClient.send(new UpdateCommand({
        TableName: "Users",
        Key: { id: patientId },
        UpdateExpression: "set assignedDoctorId = :doctorId",
        ExpressionAttributeValues: { ":doctorId": doctorId },
        ReturnValues: "ALL_NEW"
      }));
      return data.Attributes;
    } catch (error) {
      console.error("DynamoDB error (linkPatientToDoctor):", error);
      throw error;
    }
  },

  async addPatientForDoctor(doctorId, patientData) {
    try {
      const newPatient = {
        id: `patient_${Date.now()}`,
        role: 'patient',
        assignedDoctorId: doctorId,
        ...patientData,
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Users",
        Item: newPatient
      }));
      return newPatient;
    } catch (error) {
      console.error("DynamoDB error (addPatientForDoctor):", error);
      throw error;
    }
  },

  // --- NEW APPOINTMENT & AVAILABILITY METHODS (Mocked for now) ---

  async getAppointmentsForUser(userId, role) {
    try {
      const filterExpr = role === 'doctor' ? "doctorId = :userId" : "patientId = :userId";
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Appointments",
        FilterExpression: filterExpr,
        ExpressionAttributeValues: { ":userId": userId }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getAppointmentsForUser):", error);
      throw error;
    }
  },



  async updateAppointmentStatus(appointmentId, status) {
    try {
      const data = await ddbDocClient.send(new UpdateCommand({
        TableName: "Appointments",
        Key: { id: appointmentId },
        UpdateExpression: "set #statusAttr = :status",
        ExpressionAttributeNames: { "#statusAttr": "status" },
        ExpressionAttributeValues: { ":status": status },
        ReturnValues: "ALL_NEW"
      }));
      return data.Attributes;
    } catch (error) {
      console.error("DynamoDB error (updateAppointmentStatus):", error);
      throw error;
    }
  },

  // --- NEW NOTIFICATIONS & CHAT METHODS ---

  async createNotification(userId, title, message) {
    // Non-fatal: notification failure should never crash the main operation
    try {
      if (!userId) return null; // skip if no recipient
      const newNotification = {
        id: `notif_${Date.now()}`,
        userId,
        title,
        message,
        isRead: false,
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Notifications",
        Item: newNotification
      }));
      return newNotification;
    } catch (error) {
      // Log but don't throw — Notifications table may not exist yet
      console.warn("[Notification skipped]:", error.message || error);
      return null;
    }
  },

  async getNotificationsForUser(userId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Notifications",
        FilterExpression: "userId = :uid",
        ExpressionAttributeValues: { ":uid": userId }
      }));
      const items = data.Items || [];
      items.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      return items;
    } catch (error) {
      console.warn("[getNotifications skipped]:", error.message || error);
      return [];
    }
  },

  async markNotificationRead(notifId) {
    try {
      console.log(`[dbService] Marking notification ${notifId} as read.`);
      await ddbDocClient.send(new UpdateCommand({
        TableName: "Notifications",
        Key: { id: notifId },
        UpdateExpression: "SET isRead = :t",
        ExpressionAttributeValues: { ":t": true }
      }));
    } catch (error) {
      console.warn("[markNotificationRead error]:", error.message || error);
    }
  },

  async markAllNotificationsRead(userId) {
    console.log(`[dbService] Marking all notifications as read for user: ${userId}`);
    try {
      // Fetch all notifications for the user
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Notifications",
        FilterExpression: "userId = :uid",
        ExpressionAttributeValues: { ":uid": userId }
      }));

      const allNotifs = data.Items || [];
      const unreadNotifs = allNotifs.filter(n => !n.isRead || n.isRead === "false");
      
      console.log(`[dbService] Found ${unreadNotifs.length} unread notifications out of ${allNotifs.length} total for user ${userId}`);

      if (unreadNotifs.length === 0) return true;

      // Update all unread to true
      const promises = unreadNotifs.map(notif => 
        ddbDocClient.send(new UpdateCommand({
          TableName: "Notifications",
          Key: { id: notif.id },
          UpdateExpression: "SET isRead = :t",
          ExpressionAttributeValues: { ":t": true }
        })).catch(err => console.error(`Error updating notification ${notif.id}:`, err))
      );

      await Promise.all(promises);
      console.log(`[dbService] Successfully marked ${unreadNotifs.length} notifications as read.`);
      return true;
    } catch (error) {
      console.error("[markAllNotificationsRead error]:", error);
      return false;
    }
  },

  async sendMessage(senderId, receiverId, messageText) {
    try {
      const newMessage = {
        id: `msg_${Date.now()}`,
        senderId,
        receiverId,
        // Create a unique composite key representing the conversation room
        conversationId: [senderId, receiverId].sort().join('_'),
        messageText,
        isRead: false,
        createdAt: new Date().toISOString()
      };

      await ddbDocClient.send(new PutCommand({
        TableName: "Messages",
        Item: newMessage
      }));

      // To minimize spam, check if there's already an unread New Message notification
      const unreadData = await ddbDocClient.send(new ScanCommand({
        TableName: "Notifications",
        FilterExpression: "userId = :uid AND title = :title AND isRead = :f",
        ExpressionAttributeValues: { 
          ":uid": receiverId,
          ":title": "New Message",
          ":f": false
        }
      }));

      // Only create a new notification if they don't already have an unread "New Message" alert
      if (!unreadData.Items || unreadData.Items.length === 0) {
        await this.createNotification(
          receiverId, 
          "New Message", 
          "You have received a new message."
        );
      }

      return newMessage;
    } catch (error) {
      console.error("DynamoDB error (sendMessage):", error);
      throw error;
    }
  },

  async getChatHistory(user1Id, user2Id) {
    try {
      const conversationId = [user1Id, user2Id].sort().join('_');
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Messages",
        FilterExpression: "conversationId = :conversationId",
        ExpressionAttributeValues: { ":conversationId": conversationId }
      }));
      
      // Sort chronologically
      const messages = data.Items || [];
      return messages.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
    } catch (error) {
      console.error("DynamoDB error (getChatHistory):", error);
      throw error;
    }
  },

  async getConversations(userId) {
    try {
      // Scanning messages for this user as sender OR receiver
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Messages",
        FilterExpression: "senderId = :uid OR receiverId = :uid",
        ExpressionAttributeValues: { ":uid": userId }
      }));

      const messages = data.Items || [];
      const conversationsMap = new Map();

      // Get last message for each conversation
      for (const msg of messages) {
        const otherId = msg.senderId === userId ? msg.receiverId : msg.senderId;
        const currentLast = conversationsMap.get(otherId);
        if (!currentLast || new Date(msg.createdAt) > new Date(currentLast.createdAt)) {
          conversationsMap.set(otherId, msg);
        }
      }

      // Convert to list and get user details for each partner
      const conversationList = [];
      for (const [otherId, lastMsg] of conversationsMap.entries()) {
        const partner = await this.getUserById(otherId);
        if (partner) {
          conversationList.push({
            otherUserId: otherId,
            otherUserName: partner.name,
            lastMessage: lastMsg.messageText,
            lastMessageTime: lastMsg.createdAt,
            unreadCount: 0 // Simplification for now
          });
        }
      }

      // Sort by last message time
      return conversationList.sort((a, b) => new Date(b.lastMessageTime) - new Date(a.lastMessageTime));
    } catch (error) {
      console.error("DynamoDB error (getConversations):", error);
      throw error;
    }
  },

  async markMessagesAsRead(senderId, currentUserId) {
    try {
      const conversationId = [senderId, currentUserId].sort().join('_');
      // Fetch all unread messages where current user is the receiver
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Messages",
        FilterExpression: "conversationId = :cid AND receiverId = :rid AND isRead = :f",
        ExpressionAttributeValues: { 
          ":cid": conversationId,
          ":rid": currentUserId,
          ":f": false
        }
      }));

      const unreadMessages = data.Items || [];
      const promises = unreadMessages.map(msg => 
        ddbDocClient.send(new UpdateCommand({
          TableName: "Messages",
          Key: { id: msg.id },
          UpdateExpression: "SET isRead = :t",
          ExpressionAttributeValues: { ":t": true }
        }))
      );

      await Promise.all(promises);
      return true;
    } catch (error) {
      console.error("DynamoDB error (markMessagesAsRead):", error);
      return false;
    }
  },

  async getUnreadMessageCount(userId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Messages",
        FilterExpression: "receiverId = :rid AND isRead = :f",
        ExpressionAttributeValues: { 
          ":rid": userId,
          ":f": false
        },
        Select: "COUNT"
      }));
      return data.Count || 0;
    } catch (error) {
      console.error("DynamoDB error (getUnreadMessageCount):", error);
      return 0;
    }
  },

  // --- NEW WOUND MANAGEMENT METHODS ---

  async createWoundRecord(patientId, doctorId, imagePath, notes) {
    try {
      const newWound = {
        id: `wound_${Date.now()}`,
        patientId,
        doctorId: doctorId || null,
        imagePath: imagePath || null,
        notes,
        status: 'pending review',
        createdAt: new Date().toISOString()
      };

      await ddbDocClient.send(new PutCommand({
        TableName: "Wounds",
        Item: newWound
      }));

      // Only notify the doctor if the patient has one assigned
      if (doctorId) {
        await this.createNotification(
          doctorId,
          "New Wound Record",
          `Patient ${patientId} has uploaded a new wound image for review.`
        );
      }

      return newWound;
    } catch (error) {
      console.error("DynamoDB error (createWoundRecord):", error);
      throw error;
    }
  },

  async getPatientWounds(patientId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Wounds",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getPatientWounds):", error);
      throw error;
    }
  },

  async getWoundsForDoctor(doctorId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Wounds",
        FilterExpression: "doctorId = :doctorId",
        ExpressionAttributeValues: { ":doctorId": doctorId }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getWoundsForDoctor):", error);
      throw error;
    }
  },

  async updateWoundStatus(woundId, status, doctorId, patientId) {
    try {
      const data = await ddbDocClient.send(new UpdateCommand({
        TableName: "Wounds",
        Key: { id: woundId },
        UpdateExpression: "set #statusAttr = :status, reviewedAt = :reviewedAt",
        ExpressionAttributeNames: { "#statusAttr": "status" },
        ExpressionAttributeValues: { 
          ":status": status,
          ":reviewedAt": new Date().toISOString()
        },
        ReturnValues: "ALL_NEW"
      }));

      // Notify the patient that their wound was reviewed
      if (patientId) {
        await this.createNotification(
          patientId,
          "Wound Record Reviewed",
          `Your recent wound record has been marked as ${status} by your doctor.`
        );
      }

      return data.Attributes;
    } catch (error) {
      console.error("DynamoDB error (updateWoundStatus):", error);
      throw error;
    }
  },

  // --- APPOINTMENTS ---

  async getAppointmentsForUser(userId, role, filters = {}) {
    try {
      const { status, startDate, endDate } = filters;
      const filterKey = role === 'doctor' ? 'doctorId' : 'patientId';
      
      let filterExpression = `${filterKey} = :uid`;
      const expressionAttributeValues = { ":uid": userId };
      const expressionAttributeNames = {};

      if (status) {
        filterExpression += " AND #st = :status";
        expressionAttributeValues[":status"] = status;
        expressionAttributeNames["#st"] = "status";
      }

      if (startDate) {
        filterExpression += " AND #dt >= :start";
        expressionAttributeValues[":start"] = startDate;
        expressionAttributeNames["#dt"] = "date";
      }

      if (endDate) {
        filterExpression += " AND #dt <= :end";
        expressionAttributeValues[":end"] = endDate;
        expressionAttributeNames["#dt"] = "date"; // Reuse if already defined
      }

      const scanParams = {
        TableName: "Appointments",
        FilterExpression: filterExpression,
        ExpressionAttributeValues: expressionAttributeValues
      };

      if (Object.keys(expressionAttributeNames).length > 0) {
        scanParams.ExpressionAttributeNames = expressionAttributeNames;
      }

      const data = await ddbDocClient.send(new ScanCommand(scanParams));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getAppointmentsForUser):", error);
      throw error;
    }
  },

  async getFutureAppointments(userId, role) {
    try {
      const today = new Date().toISOString().split('T')[0];
      const filterKey = role === 'doctor' ? 'doctorId' : 'patientId';
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Appointments",
        FilterExpression: `${filterKey} = :uid AND #date >= :today`,
        ExpressionAttributeNames: { "#date": "date" },
        ExpressionAttributeValues: { ":uid": userId, ":today": today }
      }));
      const items = data.Items || [];
      // Sort by date then time
      return items.sort((a, b) => {
        if (a.date !== b.date) return a.date.localeCompare(b.date);
        return a.time.localeCompare(b.time);
      });
    } catch (error) {
      console.error("DynamoDB error (getFutureAppointments):", error);
      return [];
    }
  },

  async deleteAppointment(id) {
    try {
      await ddbDocClient.send(new DeleteCommand({
        TableName: "Appointments",
        Key: { id }
      }));
      return true;
    } catch (error) {
      console.error("DynamoDB error (deleteAppointment):", error);
      throw error;
    }
  },

  async createAppointment(patientId, doctorId, date, time, notes) {
    try {
      const newAppt = {
        id: `appt_${Date.now()}`,
        patientId,
        doctorId,
        date,
        time,
        notes: notes || '',
        status: 'scheduled',
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Appointments",
        Item: newAppt
      }));
      return newAppt;
    } catch (error) {
      console.error("DynamoDB error (createAppointment):", error);
      throw error;
    }
  },

  async updateAppointmentStatus(id, status) {
    try {
      await ddbDocClient.send(new UpdateCommand({
        TableName: "Appointments",
        Key: { id },
        UpdateExpression: "SET #st = :status",
        ExpressionAttributeNames: { "#st": "status" },
        ExpressionAttributeValues: { ":status": status }
      }));
      return true;
    } catch (error) {
      console.error("DynamoDB error (updateAppointmentStatus):", error);
      throw error;
    }
  },

  // --- AVAILABILITY ---

  async getDoctorAvailability(doctorId) {
    try {
      const user = await this.getUserById(doctorId);
      return user ? (user.availability || []) : [];
    } catch (error) {
      console.error("DynamoDB error (getDoctorAvailability):", error);
      return [];
    }
  },

  async setDoctorAvailability(doctorId, availabilityData) {
    try {
      await ddbDocClient.send(new UpdateCommand({
        TableName: "Users",
        Key: { id: doctorId },
        UpdateExpression: "SET availability = :av",
        ExpressionAttributeValues: { ":av": availabilityData }
      }));
      return availabilityData;
    } catch (error) {
      console.error("DynamoDB error (setDoctorAvailability):", error);
      throw error;
    }
  },

  // --- RECOVERY PLANS ---

  async getRecoveryPlan(patientId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "RecoveryPlans",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));
      // Assuming one active plan per patient
      return data.Items && data.Items.length > 0 ? data.Items[0] : null;
    } catch (error) {
      console.error("DynamoDB error (getRecoveryPlan):", error);
      return null;
    }
  },

  async createRecoveryPlan(patientId, planData) {
    try {
      const newPlan = {
        id: `plan_${Date.now()}`,
        patientId,
        ...planData,
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "RecoveryPlans",
        Item: newPlan
      }));
      return newPlan;
    } catch (error) {
      console.error("DynamoDB error (createRecoveryPlan):", error);
      throw error;
    }
  },

  // --- SESSIONS ---

  async createSession(patientId, sessionData) {
    try {
      const newSession = {
        id: `session_${Date.now()}`,
        patientId,
        ...sessionData,
        createdAt: new Date().toISOString()
      };
      await ddbDocClient.send(new PutCommand({
        TableName: "Sessions",
        Item: newSession
      }));
      return newSession;
    } catch (error) {
      console.error("DynamoDB error (createSession):", error);
      throw error;
    }
  },

  async getSessionsForPatient(patientId) {
    try {
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Sessions",
        FilterExpression: "patientId = :patientId",
        ExpressionAttributeValues: { ":patientId": patientId }
      }));
      const items = data.Items || [];
      // Sort chronologically descending
      return items.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    } catch (error) {
      console.error("DynamoDB error (getSessionsForPatient):", error);
      return [];
    }
  }
};

module.exports = dbService;
