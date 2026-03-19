const dbService = require('../services/dbService');

const appointmentController = {
    // GET /api/appointments
    async getAppointments(req, res) {
        try {
            // Determine user role and ID (Mocking it for now if req.user is undefined)
            // Assumes middleware sets req.user = { id: '...', role: '...' }
            const userId = req.user ? req.user.id : 'doctor_1';
            const role = req.user ? req.user.role : 'doctor';

            const appointments = await dbService.getAppointmentsForUser(userId, role);
            res.json({ statusCode: 200, data: appointments });
        } catch (error) {
            console.error('Error fetching appointments:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching appointments' });
        }
    },

    // POST /api/appointments
    async createAppointment(req, res) {
        try {
            const appointmentData = req.body;
            
            // Basic validation
            if (!appointmentData.doctorId || !appointmentData.patientId || !appointmentData.date || !appointmentData.time) {
                return res.status(400).json({ statusCode: 400, message: 'Missing required appointment fields' });
            }

            const newAppointment = await dbService.createAppointment(appointmentData);
            res.status(201).json({ statusCode: 201, data: newAppointment, message: 'Appointment created successfully' });
        } catch (error) {
            console.error('Error creating appointment:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error creating appointment' });
        }
    },

    // PUT /api/appointments/:id/status
    async updateStatus(req, res) {
        try {
            const appointmentId = req.params.id;
            const { status } = req.body;
            
            if (!status) {
                return res.status(400).json({ statusCode: 400, message: 'Status is required' });
            }

            const updatedAppointment = await dbService.updateAppointmentStatus(appointmentId, status);
            res.json({ statusCode: 200, data: updatedAppointment, message: `Appointment status updated to ${status}` });
        } catch (error) {
            console.error('Error updating appointment status:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error updating appointment status' });
        }
    }
};

module.exports = appointmentController;
