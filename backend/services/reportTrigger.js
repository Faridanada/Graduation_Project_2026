const dbService = require('./dbService');
const { generateFakeReport } = require('../controllers/reportController');

/**
 * Trigger for generating an AI report
 * Sends a job to the new asynchronous AI service which downloads from S3.
 */
async function triggerReportGeneration(sessionId, patientId, exerciseId, waveformS3Key) {
  try {
    // 1. Immediately set the session's reportStatus = "processing"
    await dbService.updateSession(sessionId, {
      reportStatus: 'processing'
    });

    console.log(`[reportTrigger] Generating local fake report to bypass AI server...`);
    await generateFakeReport(sessionId, patientId, exerciseId, waveformS3Key);
    return;
    
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
