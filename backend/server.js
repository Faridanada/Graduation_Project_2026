const express = require("express");
const app = express();
const PORT = 5000;
require("dotenv").config();
app.use(express.json());

// Import routes
const userRoutes = require("./routes/userRoutes");

app.use("/api", userRoutes);

app.get("/", (req, res) => {
  res.send("Backend running ✅");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});