const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const dbService = require("../services/dbService");

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

// ================= LOGIN =================
exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // Find user using DB abstraction
    const user = await dbService.getUserByEmail(email);

    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const secret = process.env.JWT_SECRET || "supersecretkey";

    const token = jwt.sign(
      { id: user.id, role: user.role },
      secret,
      { expiresIn: "1d" }
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
    const updatedUser = await dbService.updateUserProfile(req.user.id, {
      name,
      phoneNumber,
      profileData
    });
    
    if (!updatedUser) return res.status(404).json({ message: "User not found" });

    res.json({
      message: "Profile updated successfully",
      user: {
        id: updatedUser.id,
        name: updatedUser.name,
        email: updatedUser.email,
        phoneNumber: updatedUser.phoneNumber,
        profileData: updatedUser.profileData
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

