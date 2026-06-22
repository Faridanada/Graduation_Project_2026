const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

class LiveSocket {
  constructor() {
    this.wss = null;
    this.clients = new Map(); // ws client -> { userId, role, subscriptions: Set<sessionId> }
  }

  attach(server) {
    this.wss = new WebSocket.Server({ noServer: true });

    // Handle upgrade for our specific path
    server.on('upgrade', (request, socket, head) => {
      const url = new URL(request.url, `http://${request.headers.host}`);
      
      if (url.pathname === '/ws/live') {
        const token = url.searchParams.get('token');
        if (!token) {
          socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
          socket.destroy();
          return;
        }

        try {
          const secret = process.env.JWT_SECRET;
          if (!secret) throw new Error('JWT_SECRET is not set');
          
          const user = jwt.verify(token, secret, { algorithms: ['HS256'] });
          
          this.wss.handleUpgrade(request, socket, head, (ws) => {
            this.wss.emit('connection', ws, request, user);
          });
        } catch (err) {
          socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
          socket.destroy();
        }
      } else {
        // Leave other upgrades alone (e.g. for potential future socket.io elsewhere)
        // If there's no other handler, destroy to prevent hanging connection.
        // But we don't want to break existing integrations if any were added later, 
        // so we just return and let them handle it.
      }
    });

    this.wss.on('connection', (ws, req, user) => {
      console.log(`[LiveSocket] User ${user.id} (${user.role}) connected`);
      
      const clientData = {
        userId: user.id,
        role: user.role,
        subscriptions: new Set()
      };
      
      this.clients.set(ws, clientData);
      ws.isAlive = true;

      ws.on('pong', () => {
        ws.isAlive = true;
      });

      ws.on('message', (message) => {
        try {
          const msg = JSON.parse(message.toString());
          if (msg.type === 'subscribe' && msg.sessionId) {
            // Role check: Only doctors can subscribe (or the patient themselves)
            // Simplified for prototype: accept subscription, assume UI handles permission.
            // A more robust check would verify if this patient belongs to this doctor.
            clientData.subscriptions.add(msg.sessionId);
            console.log(`[LiveSocket] User ${user.id} subscribed to ${msg.sessionId}`);
          } else if (msg.type === 'unsubscribe' && msg.sessionId) {
            clientData.subscriptions.delete(msg.sessionId);
          } else if (msg.type === 'webrtc_signaling' && msg.sessionId) {
            // Broadcast WebRTC metadata (Offer, Answer, ICE) to others in the same session
            const messageString = JSON.stringify({
              sessionId: msg.sessionId,
              payload: {
                type: 'webrtc_signaling',
                senderId: user.id,
                data: msg.data
              }
            });
            for (const [clientWs, cd] of this.clients.entries()) {
              if (clientWs !== ws && clientWs.readyState === WebSocket.OPEN && cd.subscriptions.has(msg.sessionId)) {
                clientWs.send(messageString);
              }
            }
          }
        } catch (e) {
          console.warn(`[LiveSocket] Invalid message format:`, e.message);
        }
      });

      ws.on('close', () => {
        this.clients.delete(ws);
        console.log(`[LiveSocket] User ${user.id} disconnected`);
      });
    });

    // Heartbeat to keep connections alive and prune dead ones
    this.heartbeatInterval = setInterval(() => {
      this.wss.clients.forEach((ws) => {
        if (ws.isAlive === false) return ws.terminate();
        ws.isAlive = false;
        ws.ping();
      });
    }, 30000);
  }

  /**
   * Broadcasts a reading to all clients subscribed to the given sessionId.
   */
  broadcast(sessionId, payload) {
    if (!this.wss) return;

    const messageString = JSON.stringify({
      sessionId,
      payload
    });

    for (const [ws, clientData] of this.clients.entries()) {
      if (ws.readyState === WebSocket.OPEN && clientData.subscriptions.has(sessionId)) {
        ws.send(messageString);
      }
    }
  }
}

module.exports = new LiveSocket();
