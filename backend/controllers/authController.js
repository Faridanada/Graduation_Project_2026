const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const dbService = require("../services/dbService");
const fs = require("fs");
const path = require("path");

// ================= REGISTER =================
exports.registerUser = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    let profileData = req.body.profileData;

    // Parse profileData if it was sent as a JSON string via multipart/form-data
    if (typeof profileData === 'string') {
      try {
        profileData = JSON.parse(profileData);
      } catch (e) {
        console.error("Failed to parse profileData string:", e);
      }
    }

    if (!name || !email || !password) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ message: "Invalid email format" });
    }

    // Check if user already exists using our DB abstraction
    const existingUser = await dbService.getUserByEmail(email);

    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Define role from profileData (set by Flutter UI), default to 'patient'
    const userRole = (profileData && profileData.role) ? profileData.role : 'patient';

    // Create user using our DB abstraction, passing profileData
    const newUser = await dbService.createUser({
      name,
      email,
      password: hashedPassword,
      role: userRole,
      profileData: profileData || {} // Default to empty object if not provided
    });

    const secret = process.env.JWT_SECRET || "supersecretkey";
    const token = jwt.sign(
      { id: newUser.id, role: userRole },
      secret,
      { expiresIn: "1d" }
    );

    res.status(201).json({
      message: "User registered ✅",
      token,
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email,
        role: newUser.role,
        profileData: newUser.profileData
      }
    });

  } catch (error) {
    console.error("Register Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ================= CHECK EMAIL =================
exports.checkEmailAvailability = async (req, res) => {
  try {
    const { email } = req.query;
    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = await dbService.getUserByEmail(email);
    res.json({
      available: !user,
      message: user ? "Email already registered" : "Email available"
    });
  } catch (error) {
    console.error("Check Email Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};


// ================= LOGIN =================
exports.loginUser = async (req, res) => {
  try {
    const { email, password, rememberMe } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // Find user using DB abstraction
    const user = await dbService.getUserByEmail(email);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: "Incorrect password" });
    }

    const secret = process.env.JWT_SECRET || "supersecretkey";

    const expiresIn = rememberMe ? "30d" : "1d";

    const token = jwt.sign(
      { id: user.id, role: user.role },
      secret,
      { expiresIn }
    );

    res.json({
      message: "Login successful ✅",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        profileData: user.profileData || {}
      }
    });

  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ================= PROFILE =================
exports.getUserProfile = async (req, res) => {
  try {
    // The auth middleware populated req.user with the token payload `{ id }`
    const user = await dbService.getUserById(req.user.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      message: "Protected profile data ✅",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
        profileData: user.profileData || {}
      }
    });
  } catch (error) {
    console.error("Profile Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, phoneNumber, profileData } = req.body;
    const userId = req.user.id;

    let parsedData = profileData;
    if (typeof profileData === 'string' && profileData !== '') {
      try {
        parsedData = JSON.parse(profileData);
      } catch (e) {
        console.warn("Could not parse profileData JSON string");
      }
    }

    const updates = { 
      name, 
      phoneNumber, 
      profileData: parsedData 
    };

    if (req.file) {
      const user = await dbService.getUserById(userId);
      
      // Delete old image if it exists to save space
      if (user && user.profileImage) {
        const oldImagePath = path.resolve(user.profileImage);
        fs.unlink(oldImagePath, (err) => {
          if (err) console.warn("Error deleting old profile image:", err.message);
        });
      }
      
      updates.profileImage = req.file.path.replace(/\\/g, '/'); // Normalize path for all OS
    }

    const updatedUser = await dbService.updateUserProfile(userId, updates);
    
    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      message: "Profile updated successfully ✅",
      user: {
        id: updatedUser.id,
        name: updatedUser.name,
        email: updatedUser.email,
        phoneNumber: updatedUser.phoneNumber,
        profileImage: updatedUser.profileImage,
        profileData: updatedUser.profileData || {}
      }
    });
  } catch (error) {
    console.error("Profile Update Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ message: "Both old and new passwords are required" });
    }

    const user = await dbService.getUserById(req.user.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) return res.status(400).json({ message: "Invalid old password" });

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await dbService.updateUserPassword(req.user.id, hashedPassword);
    res.json({ message: "Password updated successfully" });
  } catch (error) {
    console.error("Password Change Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.toggle2FA = async (req, res) => {
  try {
    const { enabled } = req.body;
    
    if (enabled === undefined) {
      return res.status(400).json({ message: "Enabled status required" });
    }

    await dbService.updateUserProfile(req.user.id, { twoFactorEnabled: enabled });
    res.json({ message: `2FA ${enabled ? 'enabled' : 'disabled'} successfully` });
  } catch (error) {
    console.error("2FA Toggle Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ================= PASSWORD RECOVERY =================
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = await dbService.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Generate token
    const token = crypto.randomBytes(32).toString('hex');
    const expiry = new Date(Date.now() + 3600000).toISOString(); // 1 hour from now

    await dbService.saveResetToken(user.id, token, expiry);

    // In a real application, send the token via Email here
    // For development, we return it in the response
    res.json({
      message: "Password reset token generated successfully (Check response / email in production)",
      resetToken: token
    });
  } catch (error) {
    console.error("Forgot Password Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    const { email, token, newPassword } = req.body;
    if (!email || !token || !newPassword) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const user = await dbService.getUserByEmail(email);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (user.resetToken !== token || new Date(user.resetTokenExpiry) < new Date()) {
      return res.status(400).json({ message: "Invalid or expired token" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await dbService.updateUserPassword(user.id, hashedPassword);
    await dbService.clearResetToken(user.id);

    res.json({ message: "Password has been successfully reset" });
  } catch (error) {
    console.error("Reset Password Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

