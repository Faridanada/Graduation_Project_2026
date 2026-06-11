require("dotenv").config();
const dbService = require("./services/dbService");

async function run() {
  try {
    const patients = await dbService.getPatientsForDoctor("1773960124632");
    console.log("Found patients:", patients.length);
    console.log(JSON.stringify(patients, null, 2));
  } catch (err) {
    console.error(err);
  }
}
run();
