require("dotenv").config();
const dbService = require("../services/dbService");

(async () => {
  try {
    console.log("Verifying getPatientDetailsAndHistory for 'patient_1'...");
    const details = await dbService.getPatientDetailsAndHistory("patient_1");
    console.log("Result:", JSON.stringify(details, null, 2));
    if (details && details.profile && details.profile.id === "patient_1") {
      console.log("Verification successful!");
    } else {
      console.log("Response does not match expectations.");
    }
  } catch (err) {
    console.error("Test failed with error:", err);
  }
})();
