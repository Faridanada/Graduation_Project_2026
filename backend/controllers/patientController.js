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
    }
};

module.exports = patientController;
