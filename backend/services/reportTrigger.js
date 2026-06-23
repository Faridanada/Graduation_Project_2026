const dbService = require('./dbService');

/**
 * Stub: AI report generation is currently disabled.
 * The real AI service is being prepared (retrained SVM + Python
 * FastAPI wrapper). Once available, restore the real implementation.
 *
 * For now this just marks each completed session as having no AI
 * analysis so the UI can show a clear "No analysis available" state.
 */
async function triggerReportGeneration(sessionId) {
  try {
    await dbService.updateSession(sessionId, {
      reportStatus: 'no_ai_service',
      reportGeneratedAt: new Date().toISOString(),
    });
    console.log(
      `[reportTrigger] Session ${sessionId} marked as no_ai_service ` +
      `(AI service not yet deployed)`
    );
  } catch (err) {
    console.error(
      `[reportTrigger] Failed to mark session ${sessionId}: ${err.message}`
    );
  }
}

module.exports = { triggerReportGeneration };
