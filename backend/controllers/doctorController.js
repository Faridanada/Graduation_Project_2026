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

    // GET /api/doctor/availability
    async getAvailability(req, res) {
        try {
            if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
            const doctorId = req.user.id;
            const availability = await dbService.getDoctorAvailability(doctorId);
            res.json({ data: availability });
        } catch (error) {
            console.error('Error fetching availability:', error);
            res.status(500).json({ message: 'Server error' });
        }
    },

    // PUT /api/doctor/availability
    async setAvailability(req, res) {
        try {
            if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
            const doctorId = req.user.id;
            const { availability } = req.body;
            
            if (!availability) {
                return res.status(400).json({ message: 'Availability data is required' });
            }

            const updated = await dbService.setDoctorAvailability(doctorId, availability);
            res.json({ message: 'Availability updated successfully', data: updated });
        } catch (error) {
            console.error('Error setting availability:', error);
            res.status(500).json({ message: 'Server error' });
        }
    },

    // GET /api/doctor/patients/:id
    async getPatientProfile(req, res) {
        try {
            // Check if patient belongs to doctor (skipped advanced check for now)
            const patientId = req.params.id;
            
            const detailedProfile = await dbService.getPatientDetailsAndHistory(patientId);
            if (!detailedProfile) {
                return res.status(404).json({ statusCode: 404, message: 'Patient not found' });
            }

            res.json({ statusCode: 200, data: detailedProfile });
        } catch (error) {
            console.error('Error fetching patient profile:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching patient profile' });
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
    },

    // POST /api/doctor/patients/add
    async addPatient(req, res) {
        try {
            const doctorId = req.user.id || 'doctor_1';
            const patientData = req.body;

            // Basic validation
            if (!patientData.name || !patientData.phone) {
                return res.status(400).json({ statusCode: 400, message: 'Name and phone are required' });
            }

            const newPatient = await dbService.addPatientForDoctor(doctorId, patientData);
            res.status(201).json({ statusCode: 201, data: newPatient, message: 'Patient added successfully' });
        } catch (error) {
            console.error('Error adding patient:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error adding patient' });
        }
    },

    // POST /api/doctor/exercises/assign
    async assignExercise(req, res) {
        try {
            const doctorId = req.user.id || 'doctor_1';
            const { patientId, title, estimatedTimeMin, repsTotal, dateAssigned } = req.body;

            if (!patientId || !title || !dateAssigned) {
                return res.status(400).json({ statusCode: 400, message: 'patientId, title, and dateAssigned are required' });
            }

            const exerciseData = {
                title,
                estimatedTimeMin: estimatedTimeMin || 0,
                repsTotal: repsTotal || 1,
                repsCompleted: 0,
                dateAssigned
            };

            const newExercise = await dbService.assignExercise(patientId, doctorId, exerciseData);
            res.status(201).json({ statusCode: 201, data: newExercise, message: 'Exercise assigned successfully' });
        } catch (error) {
            console.error('Error assigning exercise:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error assigning exercise' });
        }
    },

    // GET /api/doctor/requests
    async getRequests(req, res) {
        try {
            const doctorId = req.user.id || 'doctor_1';
            const requests = await dbService.getRequests(doctorId);
            res.json({ statusCode: 200, data: requests });
        } catch (error) {
            console.error('Error fetching requests:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching requests' });
        }
    },

    // PUT /api/doctor/requests/:id/accept
    async acceptRequest(req, res) {
        try {
            const requestId = req.params.id;
            const updatedRequest = await dbService.updateRequestStatus(requestId, 'accepted');
            
            if (updatedRequest && updatedRequest.patientId && updatedRequest.doctorId) {
                // Link the patient to the doctor in the Users table
                await dbService.linkPatientToDoctor(updatedRequest.patientId, updatedRequest.doctorId);
                // Hard delete the request from DynamoDB so it is completely removed
                await dbService.deleteRequest(requestId);
            }

            res.json({ statusCode: 200, data: updatedRequest, message: 'Request accepted' });
        } catch (error) {
            console.error('Error accepting request:', error);
            if (error.message === 'Request not found') {
                return res.status(404).json({ statusCode: 404, message: 'Request not found' });
            }
            res.status(500).json({ statusCode: 500, message: 'Server error accepting request' });
        }
    },

    // PUT /api/doctor/requests/:id/reject
    async rejectRequest(req, res) {
        try {
            const requestId = req.params.id;
            const updatedRequest = await dbService.updateRequestStatus(requestId, 'rejected');
            // Hard delete the request from DynamoDB so it is completely removed
            await dbService.deleteRequest(requestId);
            res.json({ statusCode: 200, data: updatedRequest, message: 'Request rejected' });
        } catch (error) {
            console.error('Error rejecting request:', error);
            if (error.message === 'Request not found') {
                return res.status(404).json({ statusCode: 404, message: 'Request not found' });
            }
            res.status(500).json({ statusCode: 500, message: 'Server error rejecting request' });
        }
    },

    // GET /api/doctor/notifications
    async getNotifications(req, res) {
        try {
            const userId = req.user.id;
            const notifications = await dbService.getNotificationsForUser(userId);
            res.json({ statusCode: 200, data: notifications });
        } catch (error) {
            console.error('Error fetching notifications:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching notifications' });
        }
    },

    // PUT /api/doctor/notifications/:id/read
    async markNotificationRead(req, res) {
        try {
            const notifId = req.params.id;
            await dbService.markNotificationRead(notifId);
            res.json({ statusCode: 200, message: 'Notification marked as read' });
        } catch (error) {
            console.error('Error marking notification read:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error' });
        }
    }
};

module.exports = doctorController;
