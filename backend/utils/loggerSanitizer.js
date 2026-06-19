const util = require('util');

const sensitiveKeys = ['password', 'oldpassword', 'newpassword', 'token', 'resettoken', 'profiledata'];

function sanitizeString(str) {
  if (typeof str !== 'string') return str;
  // Simple regex to mask password values in strings
  return str.replace(/("password"|'password'|password)\s*[:=]\s*['"]?([^'"\s,}]+)['"]?/gi, '$1: "[FILTERED]"');
}

function sanitizeObject(obj, seen = new WeakSet()) {
  if (typeof obj !== 'object' || obj === null) return obj;
  if (seen.has(obj)) return '[Circular]';
  seen.add(obj);

  if (obj instanceof Error) {
    const sanitizedError = new Error(sanitizeString(obj.message));
    sanitizedError.stack = sanitizeString(obj.stack);
    sanitizedError.name = obj.name;
    
    for (const key of Object.getOwnPropertyNames(obj)) {
      if (key !== 'message' && key !== 'stack' && key !== 'name') {
        sanitizedError[key] = sanitizeObject(obj[key], seen);
      }
    }
    return sanitizedError;
  }

  if (Array.isArray(obj)) {
    return obj.map(item => sanitizeObject(item, seen));
  }

  const sanitized = {};
  for (const [key, value] of Object.entries(obj)) {
    const lowerKey = key.toLowerCase();
    if (sensitiveKeys.some(k => lowerKey.includes(k))) {
      sanitized[key] = '[FILTERED]';
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitizeObject(value, seen);
    } else if (typeof value === 'string') {
      // Try to parse stringified JSON
      try {
        const parsed = JSON.parse(value);
        if (typeof parsed === 'object' && parsed !== null) {
          sanitized[key] = JSON.stringify(sanitizeObject(parsed, new WeakSet()));
          continue;
        }
      } catch (e) {
        // Not a JSON string
      }
      sanitized[key] = sanitizeString(value);
    } else {
      sanitized[key] = value;
    }
  }
  return sanitized;
}

const originalLog = console.log;
const originalError = console.error;
const originalWarn = console.warn;
const originalInfo = console.info;

function processArgs(args) {
  return args.map(arg => {
    if (typeof arg === 'object' && arg !== null) {
      return sanitizeObject(arg);
    }
    if (typeof arg === 'string') {
      try {
        const parsed = JSON.parse(arg);
        if (typeof parsed === 'object' && parsed !== null) {
          return JSON.stringify(sanitizeObject(parsed));
        }
      } catch (e) {
        // ignore
      }
      return sanitizeString(arg);
    }
    return arg;
  });
}

console.log = function (...args) {
  originalLog.apply(console, processArgs(args));
};

console.error = function (...args) {
  originalError.apply(console, processArgs(args));
};

console.warn = function (...args) {
  originalWarn.apply(console, processArgs(args));
};

console.info = function (...args) {
  originalInfo.apply(console, processArgs(args));
};

module.exports = {
  sanitizeObject,
  sanitizeString
};
