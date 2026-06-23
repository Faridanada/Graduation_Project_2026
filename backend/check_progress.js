const axios = require('axios');
require('dotenv').config();

async function checkPatients() {
  try {
    // We assume the local server is running on 5000 as stated by user (node server.js running for 2m52s)
    // We need to login as doctor to get token, or we can just query DynamoDB directly using dbService
    const dbService = require('./services/dbService');
    const doctorId = 'doctor_1'; // Wait, we don't know the doctor id.
    
    // Let's just fetch all patients and their recovery plans
    const patients = await dbService.getAllPatients({});
    for (const p of patients) {
      console.log(`Patient: ${p.name} (ID: ${p.id})`);
      const plans = await dbService.getAllRecoveryPlans(p.id);
      if (plans.length > 0) {
        const activePlan = plans[0];
        console.log(`  Plan ID: ${activePlan.id}`);
        console.log(`  Phases:`);
        for (const ph of activePlan.phases || []) {
          console.log(`    Phase: ${ph.status}, isManuallyCompleted: ${ph.isManuallyCompleted}, start: ${ph.startDate}, end: ${ph.endDate}`);
        }
        
        const phases = activePlan.phases || [];
        const completed = phases.filter(ph => ph.status === 'Completed').length;
        const progress = phases.length > 0 ? Math.round((completed / phases.length) * 100) : 0;
        console.log(`  Calculated Progress: ${progress}%`);
      } else {
        console.log(`  No plans found.`);
      }
    }
  } catch (err) {
    console.error(err);
  }
}
checkPatients();
