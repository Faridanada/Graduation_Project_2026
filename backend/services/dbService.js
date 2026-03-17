const { 
  DynamoDBDocumentClient, 
  GetCommand, 
  PutCommand, 
  ScanCommand, 
  UpdateCommand 
} = require("@aws-sdk/lib-dynamodb");

// Re-importing mock data for tables that aren't created yet
const appointmentsData = require("../data/appointments");
const exercisesData = require("../data/exercises");
const { requestsList } = require("../data/requests");

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
      // Reverted to mock array until Appointments table is created
      const appointmentsToday = appointmentsData.filter(a => a.doctorId === doctorId && a.date === today);

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
    return new Promise((resolve) => {
      setTimeout(() => {
        const today = new Date().toISOString().split('T')[0];
        const appointments = appointmentsData.filter(a => {
          const isUserMatch = role === 'doctor' ? a.doctorId === userId : a.patientId === userId;
          return isUserMatch && a.date === today;
        });
        resolve(appointments);
      }, 100);
    });
  },

  async getTodayExercises(patientId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const today = new Date().toISOString().split('T')[0];
        const exercises = exercisesData.filter(e => e.patientId === patientId && e.dateAssigned === today);
        resolve(exercises);
      }, 100);
    });
  },

  async getReminders(patientId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve([
          { id: 1, text: "Take your morning medication at 9:00 AM", type: "medication" },
          { id: 2, text: "Ice your knee for 15 minutes after exercise", type: "therapy" },
          { id: 3, text: "Drink plenty of water", type: "general" }
        ]);
      }, 100);
    });
  },

  async getRequests(doctorId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const docRequests = requestsList.filter(r => r.doctorId === doctorId);
        resolve(docRequests);
      }, 100);
    });
  },

  async updateRequestStatus(requestId, status) {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        const reqIndex = requestsList.findIndex(r => r.id === requestId);
        if (reqIndex !== -1) {
          requestsList[reqIndex].status = status;
          resolve(requestsList[reqIndex]);
        } else {
          reject(new Error("Request not found"));
        }
      }, 100);
    });
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
  }
};

module.exports = dbService;
