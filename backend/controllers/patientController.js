const dbService = require('../services/dbService');
const { attachImageUrls } = require('../utils/userPresenter');

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
      const userResponse = await attachImageUrls(safeUser);
      res.json({ statusCode: 200, data: userResponse });
    } catch (error) {
      console.error('Error fetching patient profile:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching profile' });
    }
  },

  // GET /api/patient/doctor
  // Patient views their assigned doctor's info
  async getMyDoctor(req, res) {
    try {
      const patientId = req.user.id;
      const patient = await dbService.getUserById(patientId);
      if (!patient) return res.status(404).json({ statusCode: 404, message: 'Patient not found' });

      if (!patient.assignedDoctorId) {
        return res.json({ statusCode: 200, data: null, message: 'No assigned doctor' });
      }

      const doctor = await dbService.getUserById(patient.assignedDoctorId);
      if (!doctor) return res.status(404).json({ statusCode: 404, message: 'Doctor not found' });

      const { password, resetToken, resetTokenExpiry, ...safeDoctor } = doctor;
      const doctorResponse = await attachImageUrls(safeDoctor);
      res.json({ statusCode: 200, data: doctorResponse });
    } catch (error) {
      console.error('Error fetching doctor:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching doctor' });
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
      const userResponse = await attachImageUrls(safeUser);
      res.json({ statusCode: 200, data: userResponse, message: 'Profile updated successfully' });
    } catch (error) {
      console.error('Error updating patient profile:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error updating profile' });
    }
  },

  // GET /api/patient/exercises/today
  async getTodayExercises(req, res) {
    try {
      const patientId = req.user?.id;
      const dateString = req.query.date;
      const exercises = await dbService.getTodayExercises(patientId, dateString);
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
      const doctorResponse = await attachImageUrls(safeDoctor);
      res.json({ statusCode: 200, data: doctorResponse });
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

  // POST /api/patient/reminders
  async createReminder(req, res) {
    try {
      const patientId = req.user.id;
      const { text, type } = req.body;
      if (!text) {
        return res.status(400).json({ statusCode: 400, message: 'Reminder text is required' });
      }
      const newReminder = await dbService.createReminder(patientId, text, type);
      res.status(201).json({ statusCode: 201, data: newReminder, message: 'Reminder created successfully' });
    } catch (error) {
      console.error('Error creating reminder:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error creating reminder' });
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
      const unreadNotifs = notifications.filter(n => n.isRead === false || n.isRead === "false" || n.isRead === undefined).length;

      // 4. Calculate Weekly Progress (last 6 days)
      const allExercises = await dbService.getAllExercisesForPatient(patientId);
      let weeklyProgress = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
      const todayDate = new Date();
      for (let i = 5; i >= 0; i--) {
        const d = new Date();
        d.setDate(todayDate.getDate() - i);
        const dayStr = d.toISOString().split('T')[0];
        
        const dayExs = allExercises.filter(ex => {
          const exDate = new Date(ex.dateAssigned || ex.createdAt);
          return exDate.toISOString().split('T')[0] === dayStr;
        });

        if (dayExs.length > 0) {
          const comps = dayExs.reduce((sum, ex) => sum + (ex.repsCompleted >= (ex.repsTotal || 1) ? 1 : 0), 0);
          weeklyProgress[5 - i] = comps / dayExs.length;
        } else {
          // Carry over previous day's score if none assigned
          weeklyProgress[5 - i] = (i < 5) ? weeklyProgress[5 - i - 1] : 0;
        }
      }

      res.json({
        statusCode: 200,
        data: {
          exerciseStats,
          nextAppointment: nextAppt,
          unreadNotifications: unreadNotifs,
          weeklyProgress
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

  // PUT /api/patient/notifications/read-all
  async markAllNotificationsRead(req, res) {
    try {
      const patientId = req.user.id;
      await dbService.markAllNotificationsRead(patientId);
      res.json({ statusCode: 200, message: 'All notifications marked as read' });
    } catch (error) {
      console.error('Error marking all notifications read:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error marking all notifications' });
    }
  },

  // GET /api/patient/doctors
  async getAllDoctors(req, res) {
    try {
      const { name, specialty } = req.query;
      const doctors = await dbService.getAllDoctors({ name, specialty });
      const enrichedDoctors = await Promise.all(doctors.map(attachImageUrls));
      res.json({ statusCode: 200, data: enrichedDoctors });
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
  },

  // POST /api/patient/remind-doctor
  async remindDoctor(req, res) {
    try {
      const patientId = req.user.id;
      const patient = await dbService.getUserById(patientId);
      
      if (!patient || !patient.assignedDoctorId) {
        return res.status(400).json({ statusCode: 400, message: 'No doctor assigned' });
      }

      const patientName = patient.name || 'Your patient';
      await dbService.createNotification(
        patient.assignedDoctorId,
        "Recovery Plan Request",
        `${patientName} has requested you to set up a recovery plan.`
      );

      res.status(200).json({ statusCode: 200, message: 'Reminder sent to doctor' });
    } catch (error) {
      console.error('Error sending reminder to doctor:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error sending reminder' });
    }
  },

  // GET /api/patient/recovery-plan
  async getRecoveryPlan(req, res) {
    try {
      const patientId = req.user.id;
      let plan = await dbService.getRecoveryPlan(patientId);

      // We now return null if no plan exists, so the UI can show the empty state
      res.json({ statusCode: 200, data: plan });
    } catch (error) {
      console.error('Error fetching recovery plan:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching recovery plan' });
    }
  },

  // POST /api/patient/sessions
  async saveSession(req, res) {
    try {
      const patientId = req.user.id;
      const sessionData = req.body;
      
      const newSession = await dbService.createSession(patientId, sessionData);
      res.status(201).json({ statusCode: 201, data: newSession, message: 'Session saved successfully' });
    } catch (error) {
      console.error('Error saving session:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error saving session' });
    }
  },

  // GET /api/patient/sessions
  async getSessionHistory(req, res) {
    try {
      const patientId = req.user.id;
      const sessions = await dbService.getSessionsForPatient(patientId);
      res.json({ statusCode: 200, data: sessions });
    } catch (error) {
      console.error('Error fetching session history:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error fetching sessions' });
    }
  },

  // PUT /api/patient/recovery-plan/:planId/phases/:phaseIndex/complete
  async markPhaseCompleted(req, res) {
    try {
      const { planId, phaseIndex } = req.params;
      const index = parseInt(phaseIndex, 10);
      if (isNaN(index)) {
        return res.status(400).json({ statusCode: 400, message: 'Invalid phase index' });
      }

      const plan = await dbService.markPhaseCompleted(planId, index);
      
      if (plan && plan.overallProgress === 100) {
        const patientId = req.user.id;
        const patient = await dbService.getUserById(patientId);
        if (patient && patient.assignedDoctorId) {
          await dbService.createNotification(
            patient.assignedDoctorId,
            "Recovery Plan Completed",
            `${patient.name || 'Your patient'} has completely finished their recovery plan!`
          );
        }
      }

      res.json({ statusCode: 200, message: 'Phase marked as completed' });
    } catch (error) {
      console.error('Error marking phase completed:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error marking phase completed' });
    }
  },

  // POST /api/patient/notify-session-completed
  async notifySessionCompleted(req, res) {
    try {
      const patientId = req.user.id;
      const patient = await dbService.getUserById(patientId);
      
      if (!patient || !patient.assignedDoctorId) {
        return res.status(400).json({ statusCode: 400, message: 'No doctor assigned' });
      }

      const patientName = patient.name || 'Your patient';
      await dbService.createNotification(
        patient.assignedDoctorId,
        "Session Completed",
        `${patientName} has just completed an exercise session.`
      );

      res.status(200).json({ statusCode: 200, message: 'Doctor notified of session completion' });
    } catch (error) {
      console.error('Error notifying doctor of session completion:', error);
      res.status(500).json({ statusCode: 500, message: 'Server error notifying doctor' });
    }
  }
};

module.exports = patientController;
