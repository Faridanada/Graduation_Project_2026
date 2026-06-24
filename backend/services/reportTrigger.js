const dbService = require('./dbService');
const axios = require('axios');

/**
 * Triggers the AI report generation by sending a request to the Python FastAPI AI Service.
 */
async function triggerReportGeneration(sessionId, patientId, waveformS3Key) {
  try {
    // Mark the report status as pending while the AI works
    await dbService.updateSession(sessionId, {
      reportStatus: 'pending',
    });

    const aiServiceUrl = process.env.AI_SERVICE_URL || 'http://localhost:8000';
    const backendUrl = process.env.BACKEND_URL || process.env.PUBLIC_BASE_URL || 'http://localhost:5000';
    const serviceToken = process.env.AI_SERVICE_TOKEN || '7d291b5c4f69742a9b1c7e9a0c2b5d4e1f8e9a5c6d3b2a1f0e9d8c7b6a5f4e3d';
    
    // The callback endpoint on the Node backend that the AI service will PATCH to when done
    const callbackUrl = `${backendUrl}/api/sessions/${sessionId}/report`;

    const payload = {
      sessionId,
      patientId,
      waveformS3Key: waveformS3Key || "",
      callbackUrl,
      serviceToken
    };

    console.log(`[reportTrigger] Sending session ${sessionId} to AI Service at ${aiServiceUrl}/process`);

    // Make the request to the AI service
    const response = await axios.post(`${aiServiceUrl}/process`, payload);
    console.log(`[reportTrigger] AI Service acknowledged:`, response.data);

  } catch (err) {
    console.error(
      `[reportTrigger] Failed to trigger AI service for session ${sessionId}:`,
      err.response ? err.response.data : err.message
    );
    
    // Fallback status if we can't even reach the AI service
    await dbService.updateSession(sessionId, {
      reportStatus: 'failed',
      reportError: 'Failed to contact AI service'
    }).catch(e => console.error('[reportTrigger] Failed to update session failure status', e));
  }
}

module.exports = { triggerReportGeneration };
