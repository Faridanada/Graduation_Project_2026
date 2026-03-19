const dbService = require('../services/dbService');

const woundController = {
    // POST /api/wounds
    // Patients upload a new wound image and notes
    async createWoundRecord(req, res) {
        try {
            const patientId = req.user.id;
            const { doctorId, notes } = req.body;
            // The file path comes from multer via req.file (if image was provided)
            const imagePath = req.file ? req.file.path : null;

            if (!doctorId) {
                return res.status(400).json({ statusCode: 400, message: 'doctorId is required to assign review.' });
            }

            const newWound = await dbService.createWoundRecord(patientId, doctorId, imagePath, notes);
            res.status(201).json({ statusCode: 201, data: newWound, message: 'Wound record submitted and doctor notified' });
        } catch (error) {
            console.error('Error creating wound record:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error creating wound record' });
        }
    },

    // GET /api/wounds/patient/:patientId
    // Doctors and Patients can fetch wound history for a specific patient
    async getPatientWounds(req, res) {
        try {
            const requestedPatientId = req.params.patientId;
            const records = await dbService.getPatientWounds(requestedPatientId);
            res.json({ statusCode: 200, data: records });
        } catch (error) {
            console.error('Error fetching wound records:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching wound records' });
        }
    },

    // PUT /api/wounds/:id/status
    // Doctors review the wound and update status
    async updateWoundStatus(req, res) {
        try {
            const woundId = req.params.id;
            const { status, patientId } = req.body; // patientId needed for notification
            const doctorId = req.user.id;

            if (!status || !patientId) {
                return res.status(400).json({ statusCode: 400, message: 'status and patientId are required' });
            }

            const updatedWound = await dbService.updateWoundStatus(woundId, status, doctorId, patientId);
            res.json({ statusCode: 200, data: updatedWound, message: `Wound marked as ${status} and patient notified` });
        } catch (error) {
            console.error('Error updating wound status:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error updating wound status' });
        }
    }
};

module.exports = woundController;
