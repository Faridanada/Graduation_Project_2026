const liveSocket = require('./liveSocket');

const WARNINGS = {
  ELECTRODE_LOOSE_1: {
    severity: 'moderate',
    channel: 'emg1',
    durationMs: 500,
    message: 'EMG sensor 1 contact lost. Reattach.',
  },
  ELECTRODE_LOOSE_2: {
    severity: 'moderate',
    channel: 'emg2',
    durationMs: 500,
    message: 'EMG sensor 2 contact lost. Reattach.',
  },
  MUSCLE_ASYMMETRY: {
    severity: 'mild',
    channel: 'both',
    durationMs: 3000,
    message: 'Muscle activation asymmetric.',
  },
  NO_MUSCLE_ACTIVITY: {
    severity: 'mild',
    channel: 'both',
    durationMs: 3000,
    message: 'No muscle activity detected.',
  },
};

// Per-session state:
//   sessionState[sessionId] = {
//     ELECTRODE_LOOSE_1: { firstSeenAt: <ts> | null, active: bool },
//     ELECTRODE_LOOSE_2: { ... },
//     ...
//   }
const sessionState = new Map();

function getState(sessionId) {
  if (!sessionState.has(sessionId)) {
    const s = {};
    for (const code of Object.keys(WARNINGS)) {
      s[code] = { firstSeenAt: null, active: false };
    }
    sessionState.set(sessionId, s);
  }
  return sessionState.get(sessionId);
}

function evaluateCondition(code, reading) {
  switch (code) {
    case 'ELECTRODE_LOOSE_1':  return reading.on1 === 0;
    case 'ELECTRODE_LOOSE_2':  return reading.on2 === 0;
    case 'MUSCLE_ASYMMETRY':   return Math.abs(reading.emg1 - reading.emg2) > 25;
    case 'NO_MUSCLE_ACTIVITY': return reading.emg1 < 5 && reading.emg2 < 5;
    default: return false;
  }
}

function emitWarning(sessionId, code, ts) {
  const def = WARNINGS[code];
  liveSocket.broadcast(sessionId, {
    kind: 'warning',
    data: {
      code,
      severity: def.severity,
      channel: def.channel,
      message: def.message,
      ts,
    },
  });
  console.log(`[warningDetector] FIRED ${code} for session ${sessionId}`);
}

function emitCleared(sessionId, code, ts) {
  liveSocket.broadcast(sessionId, {
    kind: 'warning_cleared',
    data: { code, ts },
  });
  console.log(`[warningDetector] CLEARED ${code} for session ${sessionId}`);
}

/**
 * Call once per bundle. reading = the bundle payload (has on1, on2,
 * emg1, emg2, ts fields).
 */
function processReading(sessionId, reading) {
  if (!sessionId) return;
  const state = getState(sessionId);
  const now = reading.ts || Date.now();

  for (const code of Object.keys(WARNINGS)) {
    const def = WARNINGS[code];
    const triggered = evaluateCondition(code, reading);
    const entry = state[code];

    if (triggered) {
      if (entry.firstSeenAt === null) {
        entry.firstSeenAt = now;
      }
      const elapsed = now - entry.firstSeenAt;
      if (!entry.active && elapsed >= def.durationMs) {
        entry.active = true;
        emitWarning(sessionId, code, now);
      }
    } else {
      // Condition not currently true
      if (entry.active) {
        emitCleared(sessionId, code, now);
      }
      entry.firstSeenAt = null;
      entry.active = false;
    }
  }
}

/**
 * Called when a session ends. Clears all state for that session.
 * Note: do NOT emit warning_cleared messages on session end —
 * session is done, clients have unsubscribed.
 */
function resetSession(sessionId) {
  sessionState.delete(sessionId);
}

module.exports = { processReading, resetSession };
