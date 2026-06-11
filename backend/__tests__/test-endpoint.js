require("dotenv").config();
const jwt = require("jsonwebtoken");
const axios = require("axios");
const fs = require("fs");

async function test() {
  const token = jwt.sign(
    { id: "1773960124632", role: "doctor" },
    process.env.JWT_SECRET || "supersecretkey",
    { expiresIn: "10d" }
  );

  const out = {};
  
  try {
    const res = await axios.get("http://localhost:5000/api/doctor/patients", {
      headers: { Authorization: `Bearer ${token}` }
    });
    out.patients = res.data;
  } catch (err) {
    out.patientsError = err.response ? err.response.data : err.message;
  }

  try {
    const stats = await axios.get("http://localhost:5000/api/doctor/stats", {
      headers: { Authorization: `Bearer ${token}` }
    });
    out.stats = stats.data;
  } catch (err) {
    out.statsError = err.response ? err.response.data : err.message;
  }

  try {
    const apts = await axios.get("http://localhost:5000/api/doctor/appointments/today", {
      headers: { Authorization: `Bearer ${token}` }
    });
    out.apts = apts.data;
  } catch (err) {
    out.aptsError = err.response ? err.response.data : err.message;
  }

  fs.writeFileSync("api-test.json", JSON.stringify(out, null, 2), "utf-8");
}
test();
