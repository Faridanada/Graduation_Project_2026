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

// Check if email already exists
router.get("/check-email", authController.checkEmailAvailability);

// Get the profile of the current authenticated user
router.get("/profile", authMiddleware, authController.getUserProfile);
router.put("/profile", authMiddleware, upload.single("profileImage"), authController.updateProfile);
router.put("/change-password", authMiddleware, authController.changePassword);
router.put("/2fa", authMiddleware, authController.toggle2FA);

// Password recovery
router.post("/forgot-password", authController.forgotPassword);
router.post("/reset-password", authController.resetPassword);

module.exports = router;