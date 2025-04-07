import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class WebRTCService {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isLocalStreamInitialized = false;
  String _errorMessage = '';

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;
  MediaStream? get remoteStream => _peerConnection?.getRemoteStreams().isNotEmpty == true
      ? _peerConnection?.getRemoteStreams()[0]
      : null;
  bool get isLocalStreamInitialized => _isLocalStreamInitialized;
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    try {
      await _initRenderers();
      await _initializeWebRTC();
    } catch (e) {
      print('WebRTC 초기화 오류: $e');
      _errorMessage = 'WebRTC를 초기화할 수 없습니다.';
    }
  }

  Future<void> _initRenderers() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
    } catch (e) {
      print('렌더러 초기화 오류: $e');
      _errorMessage = '비디오 렌더러를 초기화할 수 없습니다.';
    }
  }

  Future<void> _initializeWebRTC() async {
    try {
      // 로컬 스트림 초기화
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': 640,
          'height': 480,
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      if (_localStream != null) {
        _localRenderer.srcObject = _localStream;
        _isLocalStreamInitialized = true;
        _errorMessage = '';
      }

      // WebRTC 연결 설정
      final configuration = <String, dynamic>{
        'iceServers': [
          {'url': 'stun:stun.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      // 로컬 스트림의 트랙을 피어커넥션에 추가
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // 원격 스트림 처리
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams[0];
        }
      };

      // ICE 후보자 처리
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        print('새로운 ICE 후보자: ${candidate.candidate}');
      };

      // 연결 상태 변경 처리
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        print('연결 상태 변경: $state');
      };

    } catch (e) {
      print('WebRTC 초기화 오류: $e');
      _errorMessage = '카메라와 마이크를 사용할 수 없습니다. 설정을 확인해주세요.';
    }
  }

  void toggleAudio(bool enabled) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  void toggleVideo(bool enabled) {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
  }
} 