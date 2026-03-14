const usersData = require("../data/users");
const appointmentsData = require("../data/appointments");
const exercisesData = require("../data/exercises");
const { requestsList } = require("../data/requests");
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
  },

  /**
   * Fetch all patients assigned to a specific doctor
   */
  async getPatientsForDoctor(doctorId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        // Find users who have role='patient' (we could match doctorId if the dataset had it, 
        // but for now let's just return all patients)
        const patients = usersData.filter(u => u.role === 'patient');
        resolve(patients);
      }, 100);
    });
  },

  /**
   * Fetch dashboard stats for a doctor
   */
  async getDashboardStats(doctorId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const patients = usersData.filter(u => u.role === 'patient');
        const appointmentsToday = appointmentsData.filter(a => a.doctorId === doctorId && a.date === new Date().toISOString().split('T')[0]);

        resolve({
          activePatients: patients.length,
          todaySessions: appointmentsToday.length,
          alerts: 3, // Mock alert count
          pendingReviews: 2,
        });
      }, 100);
    });
  },

  /**
   * Fetch today's appointments for either a patient or doctor
   */
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

  /**
   * Fetch today's exercises for a patient
   */
  async getTodayExercises(patientId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const today = new Date().toISOString().split('T')[0];
        const exercises = exercisesData.filter(e => e.patientId === patientId && e.dateAssigned === today);
        resolve(exercises);
      }, 100);
    });
  },

  /**
   * Fetch generic reminders for a patient
   */
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

  /**
   * Fetch all requests for a specific doctor
   */
  async getRequests(doctorId) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const docRequests = requestsList.filter(r => r.doctorId === doctorId);
        resolve(docRequests);
      }, 100);
    });
  },

  /**
   * Update the status of a request
   */
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

  /**
   * Add a new patient manually for a doctor
   */
  async addPatientForDoctor(doctorId, patientData) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const newPatient = {
          id: `patient_${Date.now()}`,
          role: 'patient',
          assignedDoctorId: doctorId,
          ...patientData,
          createdAt: new Date().toISOString()
        };
        usersData.push(newPatient);
        resolve(newPatient);
      }, 150);
    });
  }
};

module.exports = dbService;
