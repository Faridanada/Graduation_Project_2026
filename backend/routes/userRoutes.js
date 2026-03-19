const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");
const authMiddleware = require("../middleware/authMiddleware");
const multer = require("multer");

const upload = multer({ dest: "uploads/" });

// ================= ROUTES =================

// Register a new user
router.post("/register", upload.single("profileImage"), authController.registerUser);

// Login a user
router.post("/login", authController.loginUser);

// Get the profile of the current authenticated user
router.get("/profile", authMiddleware, authController.getUserProfile);

module.exports = router;