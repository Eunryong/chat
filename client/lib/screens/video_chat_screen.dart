import 'package:flutter/material.dart';
import '../widgets/video_view.dart';
import '../widgets/control_buttons.dart';
import '../services/webrtc_service.dart';

class VideoChatScreen extends StatefulWidget {
  const VideoChatScreen({super.key});

  @override
  State<VideoChatScreen> createState() => _VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  final WebRTCService _webRTCService = WebRTCService();
  bool _isMuted = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    _webRTCService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 원격 비디오 (전체 화면)
          Center(
            child: _webRTCService.remoteStream != null
                ? VideoView(
                    renderer: _webRTCService.remoteRenderer,
                    isLocal: false,
                  )
                : Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '연결 대기 중...',
                            style: TextStyle(color: Colors.white),
                          ),
                          if (_webRTCService.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                _webRTCService.errorMessage,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
          // 로컬 비디오 (작은 화면)
          Positioned(
            right: 20,
            top: 40,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _webRTCService.isLocalStreamInitialized
                    ? VideoView(
                        renderer: _webRTCService.localRenderer,
                        isLocal: true,
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                              if (_webRTCService.errorMessage.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '권한 필요',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          // 컨트롤 버튼
          ControlButtons(
            isMuted: _isMuted,
            isVideoOff: _isVideoOff,
            onMuteToggle: () {
              setState(() {
                _isMuted = !_isMuted;
                _webRTCService.toggleAudio(!_isMuted);
              });
            },
            onVideoToggle: () {
              setState(() {
                _isVideoOff = !_isVideoOff;
                _webRTCService.toggleVideo(!_isVideoOff);
              });
            },
            onEndCall: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _webRTCService.dispose();
    super.dispose();
  }
} 