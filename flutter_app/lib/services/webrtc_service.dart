import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  WebSocket? _socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  Function(MediaStream stream)? onRemoteStream;
  Function(MediaStream stream)? onLocalStream;
  Function()? onConnectionState;
  
  final StreamController<Map<String, dynamic>> _signalingController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get signalingStream => _signalingController.stream;

  final StreamController<Map<String, dynamic>> _socketMessageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get socketMessageStream => _socketMessageController.stream;

  String? _sessionId;
  
  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  Future<void> initConnection(String sessionId, {required bool isPatient}) async {
    _sessionId = sessionId;

    final token = ApiService.currentToken ?? '';
    final wsUrl = ApiService.baseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '/ws/live?token=$token');

    try {
      _socket = await WebSocket.connect(wsUrl);
      
      // Subscribe to the session
      _socket!.add(jsonEncode({
        'type': 'subscribe',
        'sessionId': sessionId
      }));

      _socket!.listen((data) {
        _handleSocketMessage(data, isPatient);
      }, onDone: () {
        print('WebSocket closed');
      });

      // We only want to init WebRTC media automatically if this is not just a signaling-only connection,
      // but for now we'll keep the existing behavior to avoid breaking current functionality.
      await _initWebRTC(isPatient);

    } catch (e) {
      print('WebSocket error: $e');
    }
  }

  Future<void> _initWebRTC(bool isPatient) async {
    final Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _sendSignalingMessage({
        'webrtc_type': 'ice_candidate',
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      onRemoteStream?.call(stream);
    };

    _peerConnection!.onConnectionState = (state) {
      onConnectionState?.call();
    };

    // If patient, capture local media and add stream, then create offer
    if (isPatient) {
      final Map<String, dynamic> mediaConstraints = {
        "audio": true,
        "video": {
          "facingMode": "user",
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      onLocalStream?.call(_localStream!);

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // Create Offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _sendSignalingMessage({
        'webrtc_type': 'offer',
        'sdp': offer.sdp,
        'type': offer.type,
      });
    } else {
      // If Doctor (viewer), we don't capture local stream, just receive.
      // We wait for the offer to come via signaling.
    }
  }

  void _sendSignalingMessage(Map<String, dynamic> data) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonEncode({
        'type': 'webrtc_signaling',
        'sessionId': _sessionId,
        'data': data
      }));
    }
  }

  void sendCustomSignaling({required String targetSessionId, required Map<String, dynamic> data}) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonEncode({
        'type': 'webrtc_signaling',
        'sessionId': targetSessionId,
        'data': data
      }));
    }
  }

  void subscribeToSession(String sessionId) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonEncode({
        'type': 'subscribe',
        'sessionId': sessionId
      }));
    }
  }

  void _handleSocketMessage(dynamic message, bool isPatient) async {
    try {
      final Map<String, dynamic> msg = jsonDecode(message);
      if (msg['payload'] != null) {
        // Broadcast all payloads generically so SensorDataService can pick up 'bundle' kinds
        _socketMessageController.add(msg['payload']);

        // Existing WebRTC logic
        if (msg['payload']['type'] == 'webrtc_signaling' || msg['payload']['kind'] == 'webrtc_signaling') {
          // Note: sometimes it's nested as data['webrtc_type']
          final data = msg['payload']['data'];
          if (data != null && data['webrtc_type'] != null) {
            final webrtcType = data['webrtc_type'];

            // Broadcast any custom signaling to the stream
            if (webrtcType != 'offer' && webrtcType != 'answer' && webrtcType != 'ice_candidate') {
              _signalingController.add(data);
            }

            if (webrtcType == 'offer' && !isPatient) {
              // Doctor receives offer from patient
              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(data['sdp'], data['type'])
              );
              
              RTCSessionDescription answer = await _peerConnection!.createAnswer();
              await _peerConnection!.setLocalDescription(answer);

              _sendSignalingMessage({
                'webrtc_type': 'answer',
                'sdp': answer.sdp,
                'type': answer.type,
              });
            } else if (webrtcType == 'answer' && isPatient) {
              // Patient receives answer from doctor
              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(data['sdp'], data['type'])
              );
            } else if (webrtcType == 'ice_candidate') {
              final candidateMap = data['candidate'];
              await _peerConnection!.addCandidate(
                RTCIceCandidate(
                  candidateMap['candidate'],
                  candidateMap['sdpMid'],
                  candidateMap['sdpMLineIndex'],
                )
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void dispose() {
    _socket?.close();
    _localStream?.dispose();
    _peerConnection?.close();
    _peerConnection?.dispose();
    _socket = null;
    _localStream = null;
    _peerConnection = null;
  }
}
