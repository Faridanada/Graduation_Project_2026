const dbService = require('../services/dbService');

const doctorController = {
    // GET /api/doctor/stats
    async getStats(req, res) {
        try {
            // In a real app we'd get the doctor ID from req.user
            const doctorId = req.user.id || 'doctor_1';
            const stats = await dbService.getDashboardStats(doctorId);
            res.json({ statusCode: 200, data: stats });
        } catch (error) {
            console.error('Error fetching doctor stats:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching stats' });
        }
    },

    // GET /api/doctor/patients
    async getPatients(req, res) {
        try {
            const doctorId = req.user.id || 'doctor_1';
            const patients = await dbService.getPatientsForDoctor(doctorId);
            res.json({ statusCode: 200, data: patients });
        } catch (error) {
            console.error('Error fetching patients:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching patients' });
        }
    },

    // GET /api/doctor/appointments/today
    async getTodayAppointments(req, res) {
        try {
            const doctorId = req.user.id || 'doctor_1';
            const appointments = await dbService.getTodayAppointments(doctorId, 'doctor');
            res.json({ statusCode: 200, data: appointments });
        } catch (error) {
            console.error('Error fetching today appointments:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching appointments' });
        }
    }
};

module.exports = doctorController;
