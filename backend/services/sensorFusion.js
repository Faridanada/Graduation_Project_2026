const THRESHOLD = 10; // Minimum angle change to count as a rep
const DEBOUNCE_TIME = 1000; // 1 second debounce for rep counting
const ALPHA = 0.98; // Complementary filter constant

class SensorFusion {
  constructor() {
    this.sessions = new Map();
  }

  getSessionState(sessionId) {
    if (!this.sessions.has(sessionId)) {
      this.sessions.set(sessionId, {
        thighAngle: 0,
        calfAngle: 0,
        lastTimestamp: null,
        calibrationOffset: 0,
        repCount: 0,
        lastRepPeak: 0,
        lastRepValley: 0,
        repState: 'WAITING', // WAITING -> EXTENDING -> FLEXING
        lastRepTime: 0
      });
    }
    return this.sessions.get(sessionId);
  }

  processBundle(sessionId, payload) {
    const state = this.getSessionState(sessionId);
    
    // Convert ms to seconds for dt
    const dt = state.lastTimestamp ? (payload.ts - state.lastTimestamp) / 1000.0 : 0.02; // default to 50Hz
    state.lastTimestamp = payload.ts;

    // TODO: Verify IMU Axis Mapping
    // The exact axes for gravity and rotation depend on how the physical IMUs are mounted 
    // on the thigh and calf. We heuristically use atan2(ay, az) for the inclination 
    // and gx for the angular velocity, but this must be verified with the real hardware.
    
    // Thigh IMU (IMU 1)
    const ax1 = payload.ax1, ay1 = payload.ay1, az1 = payload.az1;
    const gx1 = payload.gx1; // assuming rotation around X axis
    let thighAccAngle = Math.atan2(ay1, az1) * (180 / Math.PI);
    let thighGyroAngle = state.thighAngle + (gx1 * dt);
    state.thighAngle = ALPHA * thighGyroAngle + (1 - ALPHA) * thighAccAngle;

    // Calf IMU (IMU 2)
    const ax2 = payload.ax2, ay2 = payload.ay2, az2 = payload.az2;
    const gx2 = payload.gx2;
    let calfAccAngle = Math.atan2(ay2, az2) * (180 / Math.PI);
    let calfGyroAngle = state.calfAngle + (gx2 * dt);
    state.calfAngle = ALPHA * calfGyroAngle + (1 - ALPHA) * calfAccAngle;

    // Compute raw knee angle
    let rawKneeAngle = state.thighAngle - state.calfAngle;
    
    // Apply calibration offset
    let kneeAngle = rawKneeAngle - state.calibrationOffset;

    // Basic Rep Counting (detecting full flexion-extension cycles)
    this._updateRepCount(state, kneeAngle, payload.ts);

    return {
      kneeAngle: Math.round(kneeAngle * 10) / 10, // 1 decimal place
      repCount: state.repCount
    };
  }

  _updateRepCount(state, kneeAngle, ts) {
    // Simple state machine for reps
    if (ts - state.lastRepTime < DEBOUNCE_TIME) return;

    if (state.repState === 'WAITING') {
      if (kneeAngle > THRESHOLD) {
        state.repState = 'FLEXING';
        state.lastRepPeak = kneeAngle;
      }
    } else if (state.repState === 'FLEXING') {
      if (kneeAngle > state.lastRepPeak) {
        state.lastRepPeak = kneeAngle;
      } else if (state.lastRepPeak - kneeAngle > THRESHOLD) {
        // Started extending
        state.repState = 'EXTENDING';
        state.lastRepValley = kneeAngle;
      }
    } else if (state.repState === 'EXTENDING') {
      if (kneeAngle < state.lastRepValley) {
        state.lastRepValley = kneeAngle;
      } else if (kneeAngle - state.lastRepValley > THRESHOLD) {
        // Finished a rep, started flexing again
        state.repCount++;
        state.lastRepTime = ts;
        state.repState = 'FLEXING';
        state.lastRepPeak = kneeAngle;
      }
    }
  }

  calibrate(sessionId) {
    const state = this.getSessionState(sessionId);
    // The current raw angle becomes the 0 point
    state.calibrationOffset = state.thighAngle - state.calfAngle;
    // Reset rep tracking
    state.repCount = 0;
    state.repState = 'WAITING';
    return state.calibrationOffset;
  }
}

module.exports = new SensorFusion();
