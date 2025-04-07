import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final bool isMuted;
  final bool isVideoOff;
  final VoidCallback onMuteToggle;
  final VoidCallback onVideoToggle;
  final VoidCallback onEndCall;

  const ControlButtons({
    super.key,
    required this.isMuted,
    required this.isVideoOff,
    required this.onMuteToggle,
    required this.onVideoToggle,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 마이크 토글
          IconButton(
            icon: Icon(
              isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
            onPressed: onMuteToggle,
          ),
          // 비디오 토글
          IconButton(
            icon: Icon(
              isVideoOff ? Icons.videocam_off : Icons.videocam,
              color: Colors.white,
              size: 32,
            ),
            onPressed: onVideoToggle,
          ),
          // 통화 종료
          IconButton(
            icon: const Icon(
              Icons.call_end,
              color: Colors.red,
              size: 32,
            ),
            onPressed: onEndCall,
          ),
        ],
      ),
    );
  }
} 