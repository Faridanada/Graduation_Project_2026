const dbService = require('./dbService');
const axios = require('axios');

/**
 * Trigger for generating an AI report
 * Sends a job to the new asynchronous AI service which downloads from S3.
 */
async function triggerReportGeneration(sessionId, patientId, waveformS3Key) {
  try {
    // 1. Immediately set the session's reportStatus = "processing"
    await dbService.updateSession(sessionId, {
      reportStatus: 'processing'
    });

    const aiUrl = process.env.AI_SERVICE_URL || 'http://192.168.1.57:8000';
    const backendIp = process.env.BACKEND_IP || '192.168.1.46';
    const backendPort = process.env.PORT || '5000';
    const callbackUrl = `http://${backendIp}:${backendPort}/api/sessions/${sessionId}/report`;
    
    // Hardcode service token for now based on test script, or use env var
    const serviceToken = process.env.SERVICE_TOKEN || "7d291b5c4f69742a9b1c7e9a0c2b5d4e1f8e9a5c6d3b2a1f0e9d8c7b6a5f4e3d";

    const payload = {
      sessionId,
      patientId,
      waveformS3Key,
      callbackUrl,
      serviceToken
    };

    console.log(`[reportTrigger] Dispatching async processing job to AI service at ${aiUrl}/process...`);
    
    // The new `/process` endpoint just acknowledges and runs in background
    const response = await axios.post(`${aiUrl}/process`, payload, {
      timeout: 10000 
    });
    
    console.log(`[reportTrigger] AI Service successfully accepted job:`, response.data);
    
  } catch (error) {
    console.error("[reportTrigger Error]:", error.message || error);
    if (error.response) {
       console.error("[reportTrigger Error Response]:", error.response.data);
    }
    // We cannot patch back easily from here because report generation happens locally... wait, if the trigger fails, we should update the DB.
    try {
      const { applyReportToSession } = require('../controllers/reportController');
      await applyReportToSession(sessionId, { error: error.message || "Failed to trigger AI service" });
    } catch (fallbackError) {
      console.error("[reportTrigger Fallback Error]:", fallbackError);
    }
  }
}

exports.triggerReportGeneration = triggerReportGeneration;
