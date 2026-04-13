const dbService = require('../services/dbService');

const appointmentController = {
  // GET /api/appointments
  async getAppointments(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      
      const { status, startDate, endDate } = req.query;
      const filters = { status, startDate, endDate };
      
      const appointments = await dbService.getAppointmentsForUser(req.user.id, req.user.role, filters);
      res.json({ data: appointments });
    } catch (error) {
      console.error('Error fetching appointments:', error);
      res.status(500).json({ message: 'Server error fetching appointments' });
    }
  },

  // POST /api/appointments
  async createAppointment(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      let patientId, doctorIdParam;
      if (req.user.role === 'doctor') {
        doctorIdParam = req.user.id;
        patientId = req.body.patientId; // Doctor selects patient
      } else {
        patientId = req.user.id;
        doctorIdParam = req.body.doctorId; // Patient selects doctor
      }

      const { date, time, notes } = req.body;

      // Validation: Date must be in the future (today or later)
      const today = new Date().toISOString().split('T')[0];
      if (date < today) {
        return res.status(400).json({ message: 'Appointment date must be in the future' });
      }

      if (!doctorIdParam || !patientId || !date || !time) {
        return res.status(400).json({ message: 'Must provide doctorId/patientId, date, and time' });
      }

      const newAppt = await dbService.createAppointment(patientId, doctorIdParam, date, time, notes);
      
      // Notify the other party
      const notifyId = req.user.role === 'doctor' ? patientId : doctorIdParam;
      await dbService.createNotification(
        notifyId, 
        'New Appointment', 
        `An appointment was booked for ${date} at ${time}.`
      );

      res.status(201).json({ message: 'Appointment booked successfully', data: newAppt });
    } catch (error) {
      console.error('Error creating appointment:', error);
      res.status(500).json({ message: 'Server error booking appointment' });
    }
  },

  // PUT /api/appointments/:id/status
  async updateStatus(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      const { status } = req.body;
      if (!['scheduled', 'completed', 'cancelled'].includes(status)) {
        return res.status(400).json({ message: 'Invalid status' });
      }

      await dbService.updateAppointmentStatus(req.params.id, status);
      res.json({ message: `Appointment marked as ${status}` });
    } catch (error) {
      console.error('Error updating appointment:', error);
      res.status(500).json({ message: 'Server error updating appointment' });
    }
  },

  // DELETE /api/appointments/:id
  async deleteAppointment(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      
      const { id } = req.params;
      await dbService.deleteAppointment(id);
      res.json({ message: 'Appointment cancelled successfully' });
    } catch (error) {
      console.error('Error deleting appointment:', error);
      res.status(500).json({ message: 'Server error cancelling appointment' });
    }
  }
};

module.exports = appointmentController;
