const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { 
  DynamoDBDocumentClient, 
  GetCommand, 
  PutCommand, 
  ScanCommand, 
  UpdateCommand 
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
      // Scanning the Users table for patients
      const data = await ddbDocClient.send(new ScanCommand({
        TableName: "Users",
        FilterExpression: "#userRole = :role",
        ExpressionAttributeNames: { "#userRole": "role" },
        ExpressionAttributeValues: { ":role": "patient" }
      }));
      return data.Items || [];
    } catch (error) {
      console.error("DynamoDB error (getPatientsForDoctor):", error);
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

      return {
        activePatients: patients.length,
        todaySessions: appointmentsToday.length,
        alerts: 3, // Mock alert count
        pendingReviews: 2,
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

  async createAppointment(appointmentData) {
    try {
      const newAppt = {
        id: `appt_${Date.now()}`,
        ...appointmentData,
        status: 'upcoming',
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

  // We don't have an availability array yet, let's just keep it in memory
  _mockAvailability: {}, 

  async getDoctorAvailability(doctorId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        // Default availability if not set
        const availability = this._mockAvailability[doctorId] || [
          { day: 'Monday', isAvailable: true, startTime: '09:00', endTime: '17:00' },
          { day: 'Tuesday', isAvailable: true, startTime: '09:00', endTime: '17:00' },
          { day: 'Wednesday', isAvailable: true, startTime: '09:00', endTime: '17:00' },
          { day: 'Thursday', isAvailable: true, startTime: '09:00', endTime: '17:00' },
          { day: 'Friday', isAvailable: true, startTime: '09:00', endTime: '14:00' },
          { day: 'Saturday', isAvailable: false, startTime: '', endTime: '' },
          { day: 'Sunday', isAvailable: false, startTime: '', endTime: '' },
        ];
        resolve(availability);
      }, 100);
    });
  },

  async setDoctorAvailability(doctorId, availabilityData) {
    return new Promise((resolve) => {
      setTimeout(() => {
        this._mockAvailability[doctorId] = availabilityData;
        resolve(availabilityData);
      }, 100);
    });
  }
};

module.exports = dbService;
