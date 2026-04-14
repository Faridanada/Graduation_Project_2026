require("dotenv").config();
const express = require("express");
const app = express();
const PORT = process.env.PORT || 5000;
app.use(express.json());

// Import routes
const userRoutes = require("./routes/userRoutes");
const doctorRoutes = require("./routes/doctorRoutes");
const patientRoutes = require("./routes/patientRoutes");
const appointmentRoutes = require("./routes/appointmentRoutes");
const woundRoutes = require("./routes/woundRoutes");
const chatRoutes = require("./routes/chatRoutes");

app.use("/api", userRoutes);
app.use("/api/doctor", doctorRoutes);
app.use("/api/patient", patientRoutes);
app.use("/api/appointments", appointmentRoutes);
app.use("/api/wounds", woundRoutes);
app.use("/api/chat", chatRoutes);

// Serve uploaded wound images as static files
// On EC2: http://<EC2-IP>:5000/uploads/wounds/<filename>
app.use("/uploads", express.static("uploads"));

app.get("/", (req, res) => {
  res.send("Backend running ✅");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});