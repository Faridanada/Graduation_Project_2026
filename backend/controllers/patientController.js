const dbService = require('../services/dbService');

const patientController = {
    // GET /api/patient/exercises/today
    async getTodayExercises(req, res) {
        try {
            // Use req.user.id in production, hardcode mock id for now if needed.
            const patientId = req.user?.id || 'patient_1';
            const exercises = await dbService.getTodayExercises(patientId);
            res.json({ statusCode: 200, data: exercises });
        } catch (error) {
            console.error('Error fetching today exercises:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching exercises' });
        }
    },

    // GET /api/patient/appointments/next
    async getNextAppointment(req, res) {
        try {
            const patientId = req.user?.id || 'patient_1';
            // Just fetch today's appointments and grab the first one as "next"
            const appointments = await dbService.getTodayAppointments(patientId, 'patient');
            const nextAppointment = appointments.length > 0 ? appointments[0] : null;
            res.json({ statusCode: 200, data: nextAppointment });
        } catch (error) {
            console.error('Error fetching next appointment:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching next appointment' });
        }
    },

    // GET /api/patient/reminders
    async getReminders(req, res) {
        try {
            const patientId = req.user?.id || 'patient_1';
            const reminders = await dbService.getReminders(patientId);
            res.json({ statusCode: 200, data: reminders });
        } catch (error) {
            console.error('Error fetching reminders:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching reminders' });
        }
    },
    // GET /api/patient/doctors
    async getAllDoctors(req, res) {
        try {
            const doctors = await dbService.getAllDoctors();
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
            
            // JWT only has ID, fetch real name and email from DB
            const userProfile = await dbService.getUserById(patientId);
            const patientName = userProfile?.name || "Unknown Patient";
            const patientEmail = userProfile?.email || "No email";
            
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
    }
};

module.exports = patientController;
