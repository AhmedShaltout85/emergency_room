import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class WebRTCService extends ChangeNotifier {
  // Replace these with your server URLs
  static const String SERVER_URL = 'http://YOUR_SERVER_IP:3000';
  static const String API_URL = 'http://YOUR_SERVER_IP:9999/video-call-server';

  // Socket.IO and WebRTC instances
  IO.Socket? _socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // ICE Servers configuration
  List<Map<String, dynamic>> _iceServers = [];

  // Connection state
  bool _isConnected = false;
  bool _isInCall = false;
  String? _currentRoomId;
  String? _remoteUserId;
  String? _currentUserId;

  // Media state
  bool _isMuted = false;
  bool _isVideoOff = false;

  // Error handling
  String? _lastError;

  // Getters
  IO.Socket? get socket => _socket;
  RTCPeerConnection? get peerConnection => _peerConnection;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isConnected => _isConnected;
  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isVideoOff => _isVideoOff;
  String? get lastError => _lastError;
  String? get currentRoomId => _currentRoomId;
  String? get currentUserId => _currentUserId;

  // Initialize the WebRTC service
  Future<bool> initialize() async {
    try {
      _setError(null);

      // Fetch ICE servers from your server
      await _fetchIceServers();

      // Connect to Socket.IO server
      await _connectToSignalingServer();

      // Generate a unique user ID
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();

      log('WebRTC Service initialized successfully');
      return true;
    } catch (e) {
      _setError('Failed to initialize WebRTC: $e');
      log('WebRTC initialization error: $e');
      return false;
    }
  }

  // Fetch ICE servers from your Spring Boot server
  Future<void> _fetchIceServers() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/api/webrtc/ice-servers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _parseIceServers(data);
        log('ICE servers fetched from server: ${_iceServers.length} servers');
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching ICE servers: $e');
      // Fallback to default STUN servers
      _iceServers = [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
        {
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject'
        },
      ];
    }
  }

  // Parse ICE servers from server response
  void _parseIceServers(Map<String, dynamic> data) {
    _iceServers.clear();

    if (data['iceServers'] is Map) {
      Map<String, dynamic> servers = data['iceServers'];
      servers.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          _iceServers.add(Map<String, dynamic>.from(value));
        }
      });
    }

    // If no servers parsed, use fallback
    if (_iceServers.isEmpty) {
      _iceServers = [
        {'urls': 'stun:stun.l.google.com:19302'},
      ];
    }
  }

  // Connect to Socket.IO signaling server
  Future<void> _connectToSignalingServer() async {
    try {
      _socket = IO.io(
          SERVER_URL,
          IO.OptionBuilder()
              .setTransports(['websocket', 'polling'])
              .enableAutoConnect()
              .setTimeout(15000)
              // .setReconnection(true)
              .setReconnectionAttempts(5)
              .setReconnectionDelay(2000)
              .build());

      _socket!.onConnect((_) {
        log('Connected to signaling server');
        _isConnected = true;
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        log('Disconnected from signaling server');
        _isConnected = false;
        notifyListeners();
      });

      _socket!.onConnectError((error) {
        log('Connection error: $error');
        _setError('Connection failed: $error');
      });

      // WebRTC signaling events
      _socket!.on('ice-servers', _handleIceServers);
      _socket!.on('room-joined', _handleRoomJoined);
      _socket!.on('user-joined', _handleUserJoined);
      _socket!.on('user-left', _handleUserLeft);
      _socket!.on('offer', _handleOffer);
      _socket!.on('answer', _handleAnswer);
      _socket!.on('ice-candidate', _handleIceCandidate);
      _socket!.on('error', _handleSocketError);

      // Wait a bit for connection to establish
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw Exception('Failed to connect to signaling server: $e');
    }
  }

  // Initialize WebRTC peer connection
  Future<void> _initializePeerConnection() async {
    try {
      final Map<String, dynamic> configuration = {
        'iceServers': _iceServers,
        'iceTransportPolicy': 'all',
        'bundlePolicy': 'max-bundle',
        'rtcpMuxPolicy': 'require',
      };

      final Map<String, dynamic> constraints = {
        'mandatory': {},
        'optional': [
          {'DtlsSrtpKeyAgreement': true},
        ],
      };

      _peerConnection = await createPeerConnection(configuration, constraints);

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (_remoteUserId != null) {
          _socket!.emit('ice-candidate', {
            'to': _remoteUserId,
            'candidate': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            }
          });
        }
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        log('Remote stream added');
        _remoteStream = stream;
        _isInCall = true;
        notifyListeners();
      };

      _peerConnection!.onRemoveStream = (MediaStream stream) {
        log('Remote stream removed');
        _remoteStream = null;
        notifyListeners();
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        log('ICE Connection State: $state');
        if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          _setError('Connection failed - check network connectivity');
        } else if (state ==
            RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          _isInCall = false;
          notifyListeners();
        }
      };

      if (_localStream != null) {
        _peerConnection!.addStream(_localStream!);
      }

      log('Peer connection initialized');
    } catch (e) {
      throw Exception('Failed to initialize peer connection: $e');
    }
  }

  // Get user media (camera and microphone)
  Future<bool> getUserMedia() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);

      if (_peerConnection != null) {
        _peerConnection!.addStream(_localStream!);
      }

      log('Local media stream obtained');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to get camera/microphone access: $e');
      log('getUserMedia error: $e');
      return false;
    }
  }

  // Join a room
  Future<void> joinRoom(String roomId) async {
    if (!_isConnected) {
      throw Exception('Not connected to signaling server');
    }

    _currentRoomId = roomId;
    _socket!.emit('join-room', roomId);
    log('Joining room: $roomId');
  }

  // Leave current room
  void leaveRoom() {
    if (_currentRoomId != null) {
      _socket!.emit('leave-room', _currentRoomId);
      _currentRoomId = null;
      _remoteUserId = null;
      _isInCall = false;

      _peerConnection?.close();
      _peerConnection = null;
      _remoteStream = null;

      notifyListeners();
      log('Left room');
    }
  }

  // Toggle microphone mute
  void toggleMute() {
    if (_localStream != null) {
      _isMuted = !_isMuted;
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
      notifyListeners();
      log('Audio ${_isMuted ? 'muted' : 'unmuted'}');
    }
  }

  // Toggle video on/off
  void toggleVideo() {
    if (_localStream != null) {
      _isVideoOff = !_isVideoOff;
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = !_isVideoOff;
      });
      notifyListeners();
      log('Video ${_isVideoOff ? 'disabled' : 'enabled'}');
    }
  }

  // Socket.IO event handlers
  void _handleIceServers(dynamic data) {
    log('Received ICE servers from server');
    if (data is Map<String, dynamic>) {
      _parseIceServers(data);
    }
  }

  void _handleRoomJoined(dynamic data) {
    log('Room joined: $data');
    // Room joined successfully, wait for other users
  }

  void _handleUserJoined(dynamic data) async {
    log('User joined: $data');
    _remoteUserId = data['userId'];

    // Initialize peer connection and create offer
    await _initializePeerConnection();
    await _createOffer();
  }

  void _handleUserLeft(dynamic data) {
    log('User left: $data');
    _remoteUserId = null;
    _isInCall = false;
    _remoteStream = null;

    _peerConnection?.close();
    _peerConnection = null;

    notifyListeners();
  }

  void _handleOffer(dynamic data) async {
    log('Received offer from: ${data['from']}');
    _remoteUserId = data['from'];

    await _initializePeerConnection();
    await _handleRemoteOffer(data['offer']);
  }

  void _handleAnswer(dynamic data) async {
    log('Received answer from: ${data['from']}');
    await _handleRemoteAnswer(data['answer']);
  }

  void _handleIceCandidate(dynamic data) async {
    log('Received ICE candidate from: ${data['from']}');
    await _handleRemoteIceCandidate(data['candidate']);
  }

  void _handleSocketError(dynamic data) {
    log('Socket error: $data');
    _setError('Socket error: ${data['message']}');
  }

  // WebRTC signaling methods
  Future<void> _createOffer() async {
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _socket!.emit('offer', {
        'to': _remoteUserId,
        'offer': {
          'type': offer.type,
          'sdp': offer.sdp,
        }
      });

      log('Offer sent to $_remoteUserId');
    } catch (e) {
      _setError('Failed to create offer: $e');
    }
  }

  Future<void> _handleRemoteOffer(Map<String, dynamic> offer) async {
    try {
      RTCSessionDescription remoteOffer =
          RTCSessionDescription(offer['sdp'], offer['type']);

      await _peerConnection!.setRemoteDescription(remoteOffer);

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _socket!.emit('answer', {
        'to': _remoteUserId,
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        }
      });

      log('Answer sent to $_remoteUserId');
    } catch (e) {
      _setError('Failed to handle offer: $e');
    }
  }

  Future<void> _handleRemoteAnswer(Map<String, dynamic> answer) async {
    try {
      RTCSessionDescription remoteAnswer =
          RTCSessionDescription(answer['sdp'], answer['type']);

      await _peerConnection!.setRemoteDescription(remoteAnswer);
      log('Answer processed from $_remoteUserId');
    } catch (e) {
      _setError('Failed to handle answer: $e');
    }
  }

  Future<void> _handleRemoteIceCandidate(
      Map<String, dynamic> candidateData) async {
    try {
      RTCIceCandidate candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );

      await _peerConnection!.addCandidate(candidate);
      log('ICE candidate added');
    } catch (e) {
      log('Failed to add ICE candidate: $e');
    }
  }

  // Error handling
  void _setError(String? error) {
    _lastError = error;
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    _socket?.disconnect();
    super.dispose();
  }
}
