import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_media.dart';

class VideoView extends StatefulWidget {
  const VideoView({required this.media, super.key});

  final ProductMedia media;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? _controller;
  Object? _terminalError;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!widget.media.isVideo) {
      setState(() => _terminalError = StateError('Unsupported video media'));
      return;
    }
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_mediaUrl(widget.media.path)),
    );
    _controller = controller;
    try {
      await controller.initialize().timeout(const Duration(seconds: 15));
      if (mounted) setState(() {});
    } catch (error) {
      await controller.dispose();
      _controller = null;
      if (mounted) setState(() => _terminalError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_terminalError != null) {
      return StoreMediaPlaceholder(
        icon: Icons.videocam_off_outlined,
        message: 'storeVideoUnavailable'.tr,
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      final poster = widget.media.posterPath;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (poster != null)
            StoreNetworkMedia(
              url: _mediaUrl(poster),
              semanticLabel: 'storeVideoPoster'.tr,
            )
          else
            const ColoredBox(color: StorePalette.navy),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          PositionedDirectional(
            start: StoreSpacing.sm,
            end: StoreSpacing.sm,
            bottom: StoreSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: StoreSpacing.xs),
              decoration: BoxDecoration(
                color: StorePalette.derivedScrim,
                borderRadius: BorderRadius.circular(StoreRadii.md),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip:
                        controller.value.isPlaying
                            ? 'storePause'.tr
                            : 'storePlay'.tr,
                    color: Colors.white,
                    onPressed: () async {
                      controller.value.isPlaying
                          ? await controller.pause()
                          : await controller.play();
                      if (mounted) setState(() {});
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: StorePalette.purple,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _muted ? 'storeUnmute'.tr : 'storeMute'.tr,
                    color: Colors.white,
                    onPressed: () async {
                      _muted = !_muted;
                      await controller.setVolume(_muted ? 0 : 1);
                      if (mounted) setState(() {});
                    },
                    icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                  ),
                  IconButton(
                    tooltip: 'storeFullscreen'.tr,
                    color: Colors.white,
                    onPressed:
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  body: Center(
                                    child: AspectRatio(
                                      aspectRatio: controller.value.aspectRatio,
                                      child: VideoPlayer(controller),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                    icon: const Icon(Icons.fullscreen),
                  ),
                ],
              ),
            ),
          ),
          if (controller.value.hasError)
            StoreMediaPlaceholder(
              icon: Icons.videocam_off_outlined,
              message: 'storeVideoUnavailable'.tr,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

String _mediaUrl(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  return '${AppConstants.appBaseUrl}${path.startsWith('/') ? '' : '/'}$path';
}
