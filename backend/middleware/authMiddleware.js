const jwt = require("jsonwebtoken");

function authMiddleware(req, res, next) {
  // Support both "Authorization: Bearer <token>" and "Authorization: <token>"
  let token = req.header("Authorization");
  
  if (!token) {
    return res.status(401).json({ message: "No token, access denied" });
  }

  // Remove "Bearer " if it's there
  if (token.startsWith("Bearer ")) {
    token = token.slice(7, token.length).trimLeft();
  }

  try {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      throw new Error("JWT_SECRET is not set");
    }

    const verified = jwt.verify(token, secret, { algorithms: ['HS256'] });
    req.user = verified;
    next();
  } catch (err) {
    res.status(401).json({ message: "Invalid token" });
  }
}

module.exports = authMiddleware;
