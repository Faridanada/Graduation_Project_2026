const dbService = require('../services/dbService');
const { attachImageUrls } = require('../utils/userPresenter');

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
            const enrichedPatients = await Promise.all(patients.map(async (p) => {
                const patient = await attachImageUrls(p);
                try {
                    const plans = await dbService.getAllRecoveryPlans(patient.id || patient._id);
                    if (plans && plans.length > 0) {
                        const activePlan = plans[0]; // Assuming first is most recent/active
                        const phases = activePlan.phases || [];
                        if (phases.length > 0) {
                            patient.progress = await dbService.getPlanProgress(activePlan.id);
                        } else {
                            patient.progress = await dbService.getPlanProgress(activePlan.id);
                        }
                        patient.hasPlan = true;
                    } else {
                        patient.progress = 0;
                        patient.hasPlan = false;
                    }
                } catch(e) {
                    console.error('Error fetching plan for progress:', e);
                    patient.progress = 0;
                    patient.hasPlan = false;
                }
                return patient;
            }));
            res.json({ statusCode: 200, data: enrichedPatients });
        } catch (error) {
            console.error('Error fetching patients:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching patients' });
        }
    },

    // GET /api/doctor/patients/all
    async getAllPatients(req, res) {
        try {
            const { name } = req.query;
            const patients = await dbService.getAllPatients({ name });
            const enrichedPatients = await Promise.all(patients.map(async (p) => {
                const patient = await attachImageUrls(p);
                try {
                    const plans = await dbService.getAllRecoveryPlans(patient.id || patient._id);
                    if (plans && plans.length > 0) {
                        const activePlan = plans[0];
                        const phases = activePlan.phases || [];
                        if (phases.length > 0) {
                            patient.progress = await dbService.getPlanProgress(activePlan.id);
                        } else {
                            patient.progress = await dbService.getPlanProgress(activePlan.id);
                        }
                        patient.hasPlan = true;
                    } else {
                        patient.progress = 0;
                        patient.hasPlan = false;
                    }
                } catch(e) {
                    console.error('Error fetching plan for progress:', e);
                    patient.progress = 0;
                    patient.hasPlan = false;
                }
                return patient;
            }));
            res.json({ statusCode: 200, data: enrichedPatients });
        } catch (error) {
            console.error('Error fetching all patients:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching all patients' });
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
            if (detailedProfile.patient) {
                detailedProfile.patient = await attachImageUrls(detailedProfile.patient);
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

    // POST /api/doctor/patients/assign
    async assignExistingPatient(req, res) {
        try {
            const doctorId = req.user.id || 'doctor_1';
            const { patientId } = req.body;

            if (!patientId) {
                return res.status(400).json({ statusCode: 400, message: 'patientId is required' });
            }

            await dbService.linkPatientToDoctor(patientId, doctorId);

            // Notify the patient
            const doctorProfile = await dbService.getUserById(doctorId);
            const docName = doctorProfile?.name || 'Your doctor';
            await dbService.createNotification(
                patientId,
                "New Doctor Assigned",
                `Dr. ${docName.replace('Dr. ', '')} has added you to their patients.`
            );

            res.status(200).json({ statusCode: 200, message: 'Patient assigned successfully' });
        } catch (error) {
            console.error('Error assigning patient:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error assigning patient' });
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

    // DELETE /api/doctor/patients/:id
    async removePatient(req, res) {
        try {
            const doctorId = req.user.id || 'doctor_1';
            const patientId = req.params.id;

            await dbService.removePatientFromDoctor(patientId, doctorId);
            res.json({ statusCode: 200, message: 'Patient removed successfully' });
        } catch (error) {
            console.error('Error removing patient:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error removing patient' });
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
                
                // Notify the patient
                const doctorProfile = await dbService.getUserById(updatedRequest.doctorId);
                const docName = doctorProfile?.name || 'Your doctor';
                await dbService.createNotification(
                    updatedRequest.patientId,
                    "Connection Accepted",
                    `Dr. ${docName.replace('Dr. ', '')} has accepted your request. You can now message them.`
                );
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
    },

    // PUT /api/doctor/notifications/read-all
    async markAllNotificationsRead(req, res) {
        try {
            const userId = req.user.id;
            await dbService.markAllNotificationsRead(userId);
            res.json({ statusCode: 200, message: 'All notifications marked as read' });
        } catch (error) {
            console.error('Error marking all notifications read:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error' });
        }
    },

    // POST /api/doctor/recovery-plan
    async createRecoveryPlan(req, res) {
        try {
            const doctorId = req.user.id;
            const planData = req.body;
            
            if (!planData.patientId) {
                return res.status(400).json({ statusCode: 400, message: 'patientId is required' });
            }

            // Optional: Get patient name for UI rendering
            const patient = await dbService.getUserById(planData.patientId);
            if (patient) {
                planData.patientName = patient.name;
            }

            const newPlan = await dbService.createRecoveryPlan(planData.patientId, planData);
            
            // Auto-generate daily exercises from the plan's startDate to endDate
            if (planData.startDate && planData.endDate && planData.exercisePlan) {
                const start = new Date(planData.startDate);
                const end = new Date(planData.endDate);
                
                // Loop through each day and assign the exercise
                for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
                    // Only assign if the date is >= today (for updates)
                    const today = new Date();
                    today.setHours(0,0,0,0);
                    if (d >= today) {
                        const dateAssigned = d.toISOString().split('T')[0];
                        const exerciseData = {
                            title: planData.exercisePlan.title || 'Therapy Exercise',
                            estimatedTimeMin: planData.exercisePlan.estimatedTimeMin || 15,
                            repsTotal: planData.exercisePlan.repsTotal || 10,
                            repsCompleted: 0,
                            mode: planData.exercisePlan.mode || 'Active Mode',
                            dateAssigned: dateAssigned,
                            planId: newPlan.id
                        };
                        await dbService.assignExercise(planData.patientId, doctorId, exerciseData);
                    }
                }
            }

            // Notify patient
            const notifTitle = planData.id ? "Recovery Plan Updated" : "New Recovery Plan";
            const notifBody = planData.id
                ? "Your doctor has updated your recovery plan."
                : "Your doctor has created a new recovery plan for you.";

            await dbService.createNotification(
                planData.patientId,
                notifTitle,
                notifBody
            );

            res.status(201).json({ statusCode: 201, data: newPlan, message: 'Recovery plan created successfully' });
        } catch (error) {
            console.error('Error creating recovery plan:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error creating recovery plan' });
        }
    },

    // PUT /api/doctor/recovery-plan/:planId/phases/:phaseIndex/approve
    async approvePhase(req, res) {
        try {
            const { planId, phaseIndex } = req.params;
            const index = parseInt(phaseIndex, 10);
            if (isNaN(index)) {
                return res.status(400).json({ statusCode: 400, message: 'Invalid phase index' });
            }

            const plan = await dbService.approvePhase(planId, index);
            
            if (plan) {
                await dbService.createNotification(
                    plan.patientId,
                    "Next Phase Approved",
                    "Your doctor has approved and unlocked the next phase of your recovery plan."
                );
            }

            res.json({ statusCode: 200, message: 'Phase approved and activated' });
        } catch (error) {
            console.error('Error approving phase:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error approving phase' });
        }
    },

    // DELETE /api/doctor/recovery-plan/:id
    async deleteRecoveryPlan(req, res) {
        try {
            const planId = req.params.id;
            
            if (!planId) {
                return res.status(400).json({ statusCode: 400, message: 'planId is required' });
            }

            await dbService.deleteRecoveryPlan(planId);
            res.json({ statusCode: 200, message: 'Recovery plan and pending exercises deleted successfully' });
        } catch (error) {
            console.error('Error deleting recovery plan:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error deleting recovery plan' });
        }
    },
};

module.exports = doctorController;
