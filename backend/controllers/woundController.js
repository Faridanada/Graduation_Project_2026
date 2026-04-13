const dbService = require('../services/dbService');

const woundController = {

  // POST /api/wounds
  // Patient submits a wound report with optional image
  async createWoundRecord(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

      const patientId = req.user.id;
      const { woundArea, painLevel, description, notes } = req.body;

      if (!woundArea || !painLevel) {
        return res.status(400).json({ message: 'Wound area and pain level are required' });
      }

      // On EC2, req.file.path will be the local server filepath served at /uploads/
      const imagePath = req.file ? req.file.path : null;

      // Lookup patient's assigned doctor from their profile
      const patient = await dbService.getUserById(patientId);
      const doctorId = patient ? patient.assignedDoctorId : null;

      const metadata = {
        woundArea,
        painLevel,
        description: description || '',
        notes: notes || ''
      };

      const newWound = await dbService.createWoundRecord(patientId, doctorId, imagePath, metadata);
      res.status(201).json({ message: 'Wound report submitted \u2705', data: newWound });
    } catch (error) {
      console.error('Error creating wound record:', error);
      res.status(500).json({ message: 'Server error creating wound record' });
    }
  },

  // GET /api/wounds
  // Patient views their own wound history
  async getMyWounds(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      const wounds = await dbService.getPatientWounds(req.user.id);
      wounds.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      res.json({ data: wounds });
    } catch (error) {
      console.error('Error fetching wounds:', error);
      res.status(500).json({ message: 'Server error fetching wounds' });
    }
  },

  // GET /api/wounds/patient/:patientId
  // Doctor views a specific patient's wound history
  async getPatientWounds(req, res) {
    try {
      const records = await dbService.getPatientWounds(req.params.patientId);
      records.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      res.json({ data: records });
    } catch (error) {
      console.error('Error fetching wound records:', error);
      res.status(500).json({ message: 'Server error fetching wound records' });
    }
  },

  // GET /api/doctor/wounds
  // Doctor views all wounds from their patients, enriched with patient names
  async getDoctorWounds(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

      const wounds = await dbService.getWoundsForDoctor(req.user.id);
      const enriched = await Promise.all(
        wounds.map(async (w) => {
          const patient = await dbService.getUserById(w.patientId);
          return { ...w, patientName: patient ? patient.name : 'Unknown Patient' };
        })
      );
      enriched.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      res.json({ data: enriched });
    } catch (error) {
      console.error('Error fetching doctor wounds:', error);
      res.status(500).json({ message: 'Server error fetching doctor wounds' });
    }
  },

  // PUT /api/wounds/:id/status
  // Doctor marks wound as reviewed or healed
  async updateWoundStatus(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      if (req.user.role !== 'doctor') {
        return res.status(403).json({ message: 'Forbidden: Only doctors can update wound status' });
      }

      const { id } = req.params;
      const { status, patientId } = req.body;

      if (!status) return res.status(400).json({ message: 'status is required' });

      const updated = await dbService.updateWoundStatus(id, status, req.user.id, patientId || null);
      res.json({ message: `Wound marked as ${status}`, data: updated });
    } catch (error) {
      console.error('Error updating wound status:', error);
      res.status(500).json({ message: 'Server error updating wound status' });
    }
  },
};

module.exports = woundController;
