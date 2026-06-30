import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_constants.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.videoUrl});
  final String videoUrl;
  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController controllerVideo;
  bool isVideo = false;
  @override
  void initState() {
    controllerVideo = VideoPlayerController.networkUrl(
        Uri.parse(AppConstants.appBaseUrl + widget.videoUrl),
      )
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 10.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.r)),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          AspectRatio(
            aspectRatio: controllerVideo.value.aspectRatio,
            child: VideoPlayer(controllerVideo),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                controllerVideo.value.isPlaying
                    ? controllerVideo.pause()
                    : controllerVideo.play();
              });
            },
            child: Icon(
              controllerVideo.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color:
                  controllerVideo.value.isPlaying
                      ? Colors.transparent
                      : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controllerVideo.dispose();
    super.dispose();
  }
}
