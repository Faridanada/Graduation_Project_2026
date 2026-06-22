const dbService = require('./dbService');
const { generateFakeReport } = require('./fakeReportGenerator');
const axios = require('axios');
const { applyReportToSession } = require('../controllers/reportController');

/**
 * Fire-and-forget trigger for generating an AI report
 */
async function triggerReportGeneration(sessionId, patientId, waveformS3Key) {
  try {
    // 1. Immediately set the session's reportStatus = "processing"
    await dbService.updateSession(sessionId, {
      reportStatus: 'processing'
    });

    const useFake = process.env.USE_FAKE_REPORTS === 'true' || typeof process.env.USE_FAKE_REPORTS === 'undefined';

    if (useFake) {
      console.log(`[reportTrigger] Using local fake report generator for session ${sessionId}`);
      // Fire and forget
      generateFakeReport(sessionId, patientId, waveformS3Key).catch(err => {
        console.error("[reportTrigger] fakeReportGenerator unhandled error:", err);
      });
    } else {
      console.log(`[reportTrigger] Calling external AI service for session ${sessionId}`);
      const aiUrl = process.env.AI_SERVICE_URL || 'http://localhost:8000';
      const publicBaseUrl = process.env.PUBLIC_BASE_URL || 'http://localhost:5000';
      
      const payload = {
        sessionId,
        waveformS3Key,
        patientId,
        callbackUrl: `${publicBaseUrl}/api/sessions/${sessionId}/report`,
        serviceToken: process.env.AI_SERVICE_TOKEN
      };

      // Call AI service (fire-and-forget from our perspective)
      // The AI service returns 200 OK immediately and processes async, 
      // or we just don't await the full processing. 
      // Assuming it's an async endpoint, we await the 200 OK.
      try {
        await axios.post(`${aiUrl}/process`, payload, {
          timeout: 5000 // 5 seconds connect timeout
        });
        console.log(`[reportTrigger] Successfully triggered AI service for session ${sessionId}`);
      } catch (httpError) {
        throw new Error(`AI service unreachable: ${httpError.message}`);
      }
    }
  } catch (error) {
    console.error("[reportTrigger Error]:", error);
    // Use internal handler to set failure state
    try {
      await applyReportToSession(sessionId, { error: error.message || "Failed to trigger report generation" });
    } catch (fallbackError) {
      console.error("[reportTrigger Fallback Error]:", fallbackError);
    }
  }
}

exports.triggerReportGeneration = triggerReportGeneration;
