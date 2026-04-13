const dbService = require('../services/dbService');

const patientController = {

  // GET /api/patient/profile
  // Patient views their own profile
  async getProfile(req, res) {
    try {
      const patientId = req.user.id;
      const user = await dbService.getUserById(patientId);
      if (!user) return res.status(404).json({ statusCode: 404, message: 'Patient not found' });

      // Strip password before sending
      const { password, resetToken, resetTokenExpiry, ...safeUser } = user;
      res.json({ statusCode: 200, data: safeUser });
    } catch (error) {
      console.error('Error fetching patient profile:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching profile' });
    }
  },

  // PUT /api/patient/profile
  // Patient updates their own profile (name, phone, address)
  async updateProfile(req, res) {
    try {
      const patientId = req.user.id;
      const { name, profileData } = req.body;

      if (!name && !profileData) {
        return res.status(400).json({ statusCode: 400, message: 'No update fields provided' });
      }

      const updated = await dbService.updateUserProfile(patientId, { name, profileData });
      const { password, resetToken, resetTokenExpiry, ...safeUser } = updated;
      res.json({ statusCode: 200, data: safeUser, message: 'Profile updated successfully' });
    } catch (error) {
      console.error('Error updating patient profile:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error updating profile' });
    }
  },

  // GET /api/patient/exercises/today
  async getTodayExercises(req, res) {
    try {
      const patientId = req.user?.id;
      const exercises = await dbService.getTodayExercises(patientId);
      res.json({ statusCode: 200, data: exercises });
    } catch (error) {
      console.error('Error fetching today exercises:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching exercises' });
    }
  },

  // GET /api/patient/exercises
  // Patient views their full exercise history (all assigned exercises)
  async getAllExercises(req, res) {
    try {
      const patientId = req.user.id;
      const exercises = await dbService.getAllExercisesForPatient(patientId);
      // Sort newest first
      exercises.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      res.json({ statusCode: 200, data: exercises });
    } catch (error) {
      console.error('Error fetching all exercises:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching exercises' });
    }
  },

  // PUT /api/patient/exercises/:id/complete
  // Patient marks an exercise as completed
  async completeExercise(req, res) {
    try {
      const patientId = req.user.id;
      const { id } = req.params;
      const { repsCompleted } = req.body;

      if (repsCompleted === undefined) {
        return res.status(400).json({ statusCode: 400, message: 'repsCompleted is required' });
      }

      const updated = await dbService.updateExerciseProgress(id, patientId, repsCompleted);
      res.json({ statusCode: 200, data: updated, message: 'Exercise progress updated' });
    } catch (error) {
      console.error('Error completing exercise:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error updating exercise' });
    }
  },

  // GET /api/patient/appointments
  // Full appointment history for the patient
  async getAppointments(req, res) {
    try {
      const patientId = req.user.id;
      const appointments = await dbService.getAppointmentsForUser(patientId, 'patient');
      appointments.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      res.json({ statusCode: 200, data: appointments });
    } catch (error) {
      console.error('Error fetching appointments:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching appointments' });
    }
  },

  // GET /api/patient/appointments/next
  async getNextAppointment(req, res) {
    try {
      const patientId = req.user?.id;
      const appointments = await dbService.getFutureAppointments(patientId, 'patient');
      const nextAppointment = appointments.length > 0 ? appointments[0] : null;
      res.json({ statusCode: 200, data: nextAppointment });
    } catch (error) {
      console.error('Error fetching next appointment:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching next appointment' });
    }
  },

  // GET /api/patient/doctor
  // Patient views their assigned doctor's info
  async getMyDoctor(req, res) {
    try {
      const patientId = req.user.id;
      const patient = await dbService.getUserById(patientId);

      if (!patient || !patient.assignedDoctorId) {
        return res.json({ statusCode: 200, data: null, message: 'No doctor assigned yet' });
      }

      const doctor = await dbService.getUserById(patient.assignedDoctorId);
      if (!doctor) return res.status(404).json({ statusCode: 404, message: 'Assigned doctor not found' });

      // Strip sensitive fields
      const { password, resetToken, resetTokenExpiry, ...safeDoctor } = doctor;
      res.json({ statusCode: 200, data: safeDoctor });
    } catch (error) {
      console.error('Error fetching assigned doctor:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching doctor' });
    }
  },

  // GET /api/patient/reminders
  async getReminders(req, res) {
    try {
      const patientId = req.user?.id;
      const reminders = await dbService.getReminders(patientId);
      res.json({ statusCode: 200, data: reminders });
    } catch (error) {
      console.error('Error fetching reminders:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching reminders' });
    }
  },

  // GET /api/patient/stats
  // Returns summary stats for the dashboard
  async getDashboardStats(req, res) {
    try {
      const patientId = req.user.id;
      
      // 1. Fetch today's exercises
      const exercises = await dbService.getTodayExercises(patientId);
      const exerciseStats = {
        total: exercises.length,
        completed: exercises.filter(ex => ex.repsCompleted >= (ex.repsTotal || 1)).length
      };

      // 2. Fetch next appointment
      const futureAppts = await dbService.getFutureAppointments(patientId, 'patient');
      const nextAppt = futureAppts.length > 0 ? futureAppts[0] : null;

      // 3. Fetch unread notifications
      const notifications = await dbService.getNotificationsForUser(patientId);
      const unreadNotifs = notifications.filter(n => !n.isRead).length;

      res.json({
        statusCode: 200,
        data: {
          exerciseStats,
          nextAppointment: nextAppt,
          unreadNotifications: unreadNotifs
        }
      });
    } catch (error) {
      console.error('Error fetching patient dashboard stats:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error' });
    }
  },

  // GET /api/patient/notifications
  // Patient views their own notifications
  async getNotifications(req, res) {
    try {
      const patientId = req.user.id;
      const notifications = await dbService.getNotificationsForUser(patientId);
      res.json({ statusCode: 200, data: notifications });
    } catch (error) {
      console.error('Error fetching patient notifications:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching notifications' });
    }
  },

  // PUT /api/patient/notifications/:id/read
  // Patient marks a notification as read
  async markNotificationRead(req, res) {
    try {
      const { id } = req.params;
      await dbService.markNotificationRead(id);
      res.json({ statusCode: 200, message: 'Notification marked as read' });
    } catch (error) {
      console.error('Error marking notification as read:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error marking notification' });
    }
  },

  // GET /api/patient/doctors
  async getAllDoctors(req, res) {
    try {
      const { name, specialty } = req.query;
      const doctors = await dbService.getAllDoctors({ name, specialty });
      res.json({ statusCode: 200, data: doctors });
    } catch (error) {
      console.error('Error fetching doctors:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching doctors' });
    }
  },

  // POST /api/patient/request
  async sendRequest(req, res) {
    try {
      const patientId = req.user.id;
      const userProfile = await dbService.getUserById(patientId);
      const patientName = userProfile?.name || 'Unknown Patient';
      const patientEmail = userProfile?.email || 'No email';
      const { doctorId } = req.body;

      if (!doctorId) {
        return res.status(400).json({ statusCode: 400, message: 'Doctor ID is required' });
      }

      const newRequest = await dbService.createRequest(patientId, doctorId, patientName, patientEmail);
      res.status(201).json({ statusCode: 201, data: newRequest, message: 'Request sent successfully' });
    } catch (error) {
      console.error('Error sending request:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error sending request' });
    }
  },

  // GET /api/patient/doctors/:id/availability
  async getDoctorAvailability(req, res) {
    try {
      const doctorId = req.params.id;
      const availability = await dbService.getDoctorAvailability(doctorId);
      res.json({ data: availability });
    } catch (error) {
      console.error('Error fetching doctor availability:', error);
      res.status(500).json({ message: 'Server error fetching availability' });
    }
  }
};

module.exports = patientController;
