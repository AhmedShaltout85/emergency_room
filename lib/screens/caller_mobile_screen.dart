import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

import '../network/remote/remote_network_repos.dart';
import '../utils/app_constants.dart';

class CallerMobileScreen extends StatefulWidget {
  final String addressTitle;
  const CallerMobileScreen({
    super.key,
    required this.addressTitle,
  });

  @override
  State<CallerMobileScreen> createState() => _CallerScreenState();
}

class _CallerScreenState extends State<CallerMobileScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late RTCPeerConnection _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final String _signalingServer =
      '$BASE_URI_IP_ADDRESS_LOCAL_HOST/webrtc-signaling-server/api/v1/mobile';
  String? _roomId;
  bool _isCalling = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;
  bool _isRemoteVideoReady = false;
  final List<RTCIceCandidate> _pendingRemoteCandidates = [];
  Timer? _candidateTimer;
  bool _hasRemoteDescription = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _createPeerConnection();
  }

  Future<void> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection.onIceCandidate = (candidate) async {
      if (_isDisposed) return;
      if (candidate.candidate!.isNotEmpty && _roomId != null) {
        try {
          await http.post(
            Uri.parse('$_signalingServer/candidate'),
            body: json.encode({
              'roomId': _roomId,
              'candidate': candidate.toMap(),
              'type': 'caller'
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          log('Error sending ICE candidate: $e');
        }
      }
    };

    _peerConnection.onIceConnectionState = (state) {
      log('ICE connection state: $state');
      if (_isDisposed) return;
      if (mounted) {
        setState(() {
          if (state ==
                  RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
              state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
              state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
            _endCall();
          }
        });
      }
    };

    _peerConnection.onTrack = (event) {
      if (_isDisposed) return;
      if (event.streams.isNotEmpty && mounted) {
        setState(() {
          _remoteStream = event.streams.first;
          _remoteRenderer.srcObject = _remoteStream;
          _isRemoteVideoReady = true;
        });
      }
    };

    _peerConnection.onConnectionState = (state) {
      log('Peer connection state: $state');
    };

    _processPendingCandidates();
  }

  Future<void> _notifyReceiver() async {
    try {
      final response = await http.post(
        Uri.parse('$_signalingServer/notify/$_roomId'),
        body: json.encode({
          'roomId': _roomId,
          'isCalling': true,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification');
      }
    } catch (e) {
      log('Error sending notification: $e');
      _showError('Failed to notify receiver: ${e.toString()}');
    }
  }

  Future<void> _startCall() async {
    try {
      setState(() {
        _isCalling = true;
        _isRemoteVideoReady = false;
      });

      final mediaConstraints = {
        'audio': true,
        'video': {
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
          'facingMode': _isFrontCamera ? 'user' : 'environment'
        }
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      for (final track in _localStream!.getTracks()) {
        _peerConnection.addTrack(track, _localStream!);
      }

      final response = await http.post(
        Uri.parse('$_signalingServer/create'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create room: ${response.body}');
      }

      _roomId = json.decode(response.body)['roomId'];
      log('Room ID: $_roomId');

      await _notifyReceiver();

      final offer = await _peerConnection.createOffer();
      await _peerConnection.setLocalDescription(offer);

      await http.post(
        Uri.parse('$_signalingServer/offer/$_roomId'),
        body: json.encode({
          'sdp': offer.sdp,
          'type': offer.type,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      _listenForAnswer();
      _startCandidateTimer();
    } catch (e) {
      log('Call error: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isCalling = false;
        });
        _showError('Failed to start call: ${e.toString()}');
      }
      _endCall();
    }
  }

  Future<void> _listenForAnswer() async {
    try {
      while (_roomId != null && mounted && !_isDisposed) {
        final response = await http.get(
          Uri.parse('$_signalingServer/answer/$_roomId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is Map && data.isNotEmpty && data['sdp'] != null) {
            final answer = RTCSessionDescription(
              data['sdp'],
              data['type'],
            );
            await _peerConnection.setRemoteDescription(answer);
            if (mounted && !_isDisposed) {
              setState(() {
                _hasRemoteDescription = true;
              });
            }
            await _processPendingCandidates();
            break;
          }
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      log('Error listening for answer: $e');
      if (mounted && !_isDisposed) {
        _showError('Failed to receive answer: ${e.toString()}');
      }
    }
  }

  void _startCandidateTimer() {
    _candidateTimer?.cancel();
    _candidateTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_roomId == null || _isDisposed) {
        timer.cancel();
        return;
      }
      await _checkForRemoteCandidates();
    });
  }

  Future<void> _checkForRemoteCandidates() async {
    try {
      final response = await http.get(
        Uri.parse('$_signalingServer/candidates/$_roomId/receiver'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> candidates = json.decode(response.body);
        for (final candidate in candidates) {
          final iceCandidate = RTCIceCandidate(
            candidate['candidate'],
            candidate['sdpMid'],
            candidate['sdpMLineIndex'],
          );

          if (_hasRemoteDescription) {
            try {
              await _peerConnection.addCandidate(iceCandidate);
            } catch (e) {
              log('Error adding candidate: $e');
              if (!_isDisposed) {
                _pendingRemoteCandidates.add(iceCandidate);
              }
            }
          } else if (!_isDisposed) {
            _pendingRemoteCandidates.add(iceCandidate);
          }
        }
      }
    } catch (e) {
      log('Error checking for candidates: $e');
    }
  }

  Future<void> _processPendingCandidates() async {
    while (_pendingRemoteCandidates.isNotEmpty) {
      final candidate = _pendingRemoteCandidates.removeAt(0);
      try {
        await _peerConnection.addCandidate(candidate);
      } catch (e) {
        log('Error adding pending candidate: $e');
        if (!_isDisposed) {
          _pendingRemoteCandidates.insert(0, candidate);
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    }
  }

  Future<void> _endCall() async {
    try {
      if (_roomId != null) {
        await http.post(
          Uri.parse('$_signalingServer/end/$_roomId'),
          headers: {'Content-Type': 'application/json'},
        );
      }

      _candidateTimer?.cancel();
      await _peerConnection.close();

      if (_localStream != null) {
        for (final track in _localStream!.getTracks()) {
          track.stop();
        }
        _localStream!.dispose();
      }

      if (_remoteStream != null) {
        for (final track in _remoteStream!.getTracks()) {
          track.stop();
        }
        _remoteStream!.dispose();
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _isCalling = false;
          _isRemoteVideoReady = false;
          _roomId = null;
          _hasRemoteDescription = false;
          _pendingRemoteCandidates.clear();
          _localStream = null;
          _remoteStream = null;
        });
      }
      //update video call
      //TODO: update video call NOT TESTED
      DioNetworkRepos()
          .updateLocationBrokenByAddressUpdateVideoCall(widget.addressTitle, 0);
      // Navigator.pop(context);
    } catch (e) {
      log('Error ending call: $e');
    }
  }

  Future<void> _toggleMute() async {
    if (_localStream == null || _isDisposed) return;

    setState(() {
      _isMuted = !_isMuted;
    });

    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = !_isMuted;
    }
  }

  Future<void> _toggleVideo() async {
    if (_localStream == null || _isDisposed) return;

    setState(() {
      _isVideoOff = !_isVideoOff;
    });

    for (final track in _localStream!.getVideoTracks()) {
      track.enabled = !_isVideoOff;
    }
  }

  Future<void> _switchCamera() async {
    if (_localStream == null || _isDisposed) return;

    try {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
      if (mounted && !_isDisposed) {
        setState(() {
          _isFrontCamera = !_isFrontCamera;
        });
      }
    } catch (e) {
      log('Error switching camera: $e');
      _showError('Failed to switch camera: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _candidateTimer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.addressTitle,
          style: const TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
        elevation: 7.0,
        // backgroundColor: Colors.white,
        // iconTheme: const IconThemeData(color: Colors.indigo),
        actions: [
          if (_roomId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Room: ${_roomId!.substring(0, 6)}...',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_isRemoteVideoReady)
                    RTCVideoView(_remoteRenderer, mirror: false),
                  if (!_isRemoteVideoReady && _isCalling)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Waiting for receiver to join...'),
                        ],
                      ),
                    ),
                  Positioned(
                    right: 20,
                    top: 20,
                    width: 120,
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: Colors.black,
                        child: RTCVideoView(
                          _localRenderer,
                          mirror: _isFrontCamera,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: _isCalling ? 'End call' : 'Start call',
                    icon: Icon(_isCalling ? Icons.call_end : Icons.call),
                    onPressed: _isCalling ? _endCall : _startCall,
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: _isCalling ? Colors.red : Colors.green,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                  IconButton(
                    tooltip: _isMuted ? 'Turn on mic' : 'Turn off mic',
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                    onPressed: _toggleMute,
                    color: _isMuted ? Colors.red : Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                  IconButton(
                    tooltip: _isVideoOff ? 'Turn on video' : 'Turn off video',
                    icon:
                        Icon(_isVideoOff ? Icons.videocam_off : Icons.videocam),
                    onPressed: _toggleVideo,
                    color: _isVideoOff ? Colors.red : Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Switch Camera',
                    icon: const Icon(Icons.switch_video),
                    onPressed: _switchCamera,
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
