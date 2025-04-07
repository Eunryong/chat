import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool isLocal;

  const VideoView({
    super.key,
    required this.renderer,
    required this.isLocal,
  });

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(
      renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirror: isLocal,
    );
  }
} 