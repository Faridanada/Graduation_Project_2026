const express = require("express");
const app = express();
const PORT = 5000;
require("dotenv").config();
app.use(express.json());

// Import routes
const userRoutes = require("./routes/userRoutes");
const doctorRoutes = require("./routes/doctorRoutes");
const patientRoutes = require("./routes/patientRoutes");
const appointmentRoutes = require("./routes/appointmentRoutes");

app.use("/api", userRoutes);
app.use("/api/doctor", doctorRoutes);
app.use("/api/patient", patientRoutes);
app.use("/api/appointments", appointmentRoutes);

app.get("/", (req, res) => {
  res.send("Backend running ✅");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});